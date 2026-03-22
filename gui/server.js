'use strict';

const express = require('express');
const Docker = require('dockerode');
const WebSocket = require('ws');
const multer = require('multer');
const tar = require('tar-stream');
const crypto = require('crypto');
const { PassThrough } = require('stream');
const path = require('path');
const { arch } = require('os');
const unzipper = require('unzipper');

// Terraria images are x86_64 only — ARM hosts need a platform override
const TERRARIA_PLATFORM = arch() === 'arm64' ? 'linux/amd64' : undefined;

const app = express();
const docker = new Docker({ socketPath: '/var/run/docker.sock' });
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 500 * 1024 * 1024 } });

const PASSWORD = process.env.GUI_PASSWORD || 'admin';
const tokens = new Map(); // token -> expiresAt

// Strip ANSI escape codes from log output
const stripAnsi = s => s.replace(/\x1b\[[0-9;]*[mGKHFJA-Za-z]/g, '');

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ── Auth ──────────────────────────────────────────────────────────────

function requireAuth(req, res, next) {
  const auth = req.headers.authorization || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : null;
  if (!token || (tokens.get(token) || 0) < Date.now()) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

function validateWsToken(req) {
  const url = new URL(req.url, 'http://localhost');
  const token = url.searchParams.get('token');
  return token && (tokens.get(token) || 0) > Date.now();
}

app.post('/api/login', (req, res) => {
  if (req.body.password !== PASSWORD) {
    return res.status(401).json({ error: 'Invalid password' });
  }
  const token = crypto.randomBytes(32).toString('hex');
  tokens.set(token, Date.now() + 24 * 60 * 60 * 1000);
  res.json({ token });
});

// ── Helpers ───────────────────────────────────────────────────────────

function isTerrariaContainer(c) {
  const img = (c.Image || '').toLowerCase();
  return (
    img.includes('terraria') ||
    img.includes('tmodloader') ||
    img.includes('passivelemon') ||
    (c.Labels && c.Labels['terraria-gui.managed'] === 'true')
  );
}

function execRead(containerId, cmd) {
  return new Promise(async (resolve, reject) => {
    try {
      const c = docker.getContainer(containerId);
      const exec = await c.exec({ Cmd: cmd, AttachStdout: true, AttachStderr: true });
      const stream = await exec.start({ hijack: true, stdin: false });
      const out = new PassThrough();
      const err = new PassThrough();
      docker.modem.demuxStream(stream, out, err);
      let buf = '';
      out.on('data', d => (buf += d.toString()));
      err.on('data', d => (buf += d.toString()));
      // Resolve on the raw stream end — PassThrough end is unreliable with demuxStream
      stream.on('end', () => resolve(buf));
      stream.on('error', reject);
    } catch (e) {
      reject(e);
    }
  });
}

function parseLs(output, dir) {
  return output
    .trim()
    .split('\n')
    .filter(l => l && !l.startsWith('total'))
    .map(l => {
      const parts = l.split(/\s+/);
      if (parts.length < 9) return null;
      const perms = parts[0];
      const size = parts[4];
      const isLink = perms.startsWith('l');
      // Symlink entries look like "foo -> bar" — use only the name before " -> "
      const rawName = parts.slice(8).join(' ');
      const name = isLink ? rawName.split(' -> ')[0] : rawName;
      if (name === '.' || name === '..') return null;
      return {
        name,
        size,
        isDir: perms.startsWith('d'),
        isLink,
        path: path.posix.join(dir, name),
      };
    })
    .filter(Boolean);
}

// ── Containers ────────────────────────────────────────────────────────

app.get('/api/containers', requireAuth, async (req, res) => {
  try {
    const all = await docker.listContainers({ all: true });
    res.json(
      all.filter(isTerrariaContainer).map(c => ({
        id: c.Id,
        name: c.Names[0].replace(/^\//, ''),
        image: c.Image,
        state: c.State,
        status: c.Status,
        type: c.Image.toLowerCase().includes('tmod') ? 'tModLoader' : 'Terraria',
      }))
    );
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/containers/:id/start', requireAuth, async (req, res) => {
  try {
    await docker.getContainer(req.params.id).start();
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/containers/:id/stop', requireAuth, async (req, res) => {
  try {
    await docker.getContainer(req.params.id).stop();
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/containers/:id/restart', requireAuth, async (req, res) => {
  try {
    await docker.getContainer(req.params.id).restart();
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Inject ────────────────────────────────────────────────────────────

app.post('/api/containers/:id/inject', requireAuth, async (req, res) => {
  const { command } = req.body;
  if (!command?.trim()) return res.status(400).json({ error: 'No command provided' });
  try {
    const c = docker.getContainer(req.params.id);
    const exec = await c.exec({
      Cmd: ['inject', command.trim()],
      AttachStdout: true,
      AttachStderr: true,
    });
    const stream = await exec.start({ hijack: true, stdin: false });
    stream.resume();
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Files ─────────────────────────────────────────────────────────────

app.get('/api/containers/:id/files', requireAuth, async (req, res) => {
  const dir = req.query.path || '/opt/terraria/config';
  try {
    const raw = await execRead(req.params.id, ['ls', '-la', dir]);
    res.json(parseLs(raw, dir));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/containers/:id/file', requireAuth, async (req, res) => {
  const filePath = req.query.path;
  if (!filePath) return res.status(400).json({ error: 'No path provided' });
  try {
    const content = await execRead(req.params.id, ['cat', filePath]);
    res.type('text/plain').send(content);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/containers/:id/upload', requireAuth, upload.single('file'), async (req, res) => {
  const dir = req.body.path || '/opt/terraria/config';
  if (!req.file) return res.status(400).json({ error: 'No file provided' });
  try {
    const c = docker.getContainer(req.params.id);
    const pack = tar.pack();
    // Use path.basename to prevent path traversal via crafted filenames
    const safeName = path.basename(req.file.originalname);
    pack.entry(
      { name: safeName, size: req.file.buffer.length },
      req.file.buffer,
      err => {
        if (err) { pack.destroy(err); return; }
        pack.finalize();
      }
    );
    await c.putArchive(pack, { path: dir });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Server create / delete ────────────────────────────────────────────

function pullImage(imageName) {
  return new Promise((resolve, reject) => {
    const opts = TERRARIA_PLATFORM ? { platform: TERRARIA_PLATFORM } : {};
    docker.pull(imageName, opts, (err, stream) => {
      if (err) return reject(err);
      docker.modem.followProgress(stream, err => (err ? reject(err) : resolve()));
    });
  });
}

async function ensureImage(imageName) {
  try { await docker.getImage(imageName).inspect(); }
  catch { await pullImage(imageName); }
}

app.post('/api/servers/create', requireAuth, upload.fields([
  { name: 'worldFile',   maxCount: 1 },
  { name: 'modpackFile', maxCount: 1 },
]), async (req, res) => {
  const files = req.files || {};
  const worldFile   = files.worldFile?.[0]   || null;
  const modpackFile = files.modpackFile?.[0] || null;

  const {
    type       = 'terraria',
    name       = `terraria-${Date.now()}`,
    port       = '7777',
    worldMode  = 'new',
    worldName  = 'World',
    autocreate = '2',
    difficulty = '0',
    worldEvil  = '',
    seed, password,
    maxPlayers = '8',
    modpackName = 'vanilla',
  } = req.body;

  if (!/^[a-zA-Z0-9_-]+$/.test(name))
    return res.status(400).json({ error: 'Name must be alphanumeric (hyphens/underscores allowed)' });

  const portNum = parseInt(port, 10);
  if (isNaN(portNum) || portNum < 1024 || portNum > 65535)
    return res.status(400).json({ error: 'Port must be between 1024 and 65535' });

  const isTml      = type === 'tmodloader';
  const imageName  = isTml
    ? 'passivelemon/terraria-docker:tmodloader-latest'
    : 'passivelemon/terraria-docker:terraria-latest';
  const volumeName = `terraria-gui-${name}-config`;
  const modpack    = (modpackName || 'vanilla').replace(/[^a-zA-Z0-9_-]/g, '_');

  // Derive world name from uploaded file when importing
  const effectiveWorld = (worldMode === 'import' && req.file)
    ? path.basename(req.file.originalname, path.extname(req.file.originalname))
    : worldName;

  let tempContainer = null;
  let volumeCreated = false;

  try {
    await ensureImage(imageName);
    await ensureImage('alpine:latest');

    // Create named volume
    await docker.createVolume({ Name: volumeName });
    volumeCreated = true;

    // Spin up a temporary Alpine container to initialise the volume
    tempContainer = await docker.createContainer({
      Image: 'alpine:latest',
      Cmd: ['sleep', '60'],
      HostConfig: { Binds: [`${volumeName}:/opt/terraria/config`] },
    });
    await tempContainer.start();

    // Create required directories (and empty modpack for tModLoader)
    const mkCmd = isTml
      ? `mkdir -p /opt/terraria/config/Worlds /opt/terraria/config/ModPacks/${modpack}/Mods && printf '[]' > /opt/terraria/config/ModPacks/${modpack}/Mods/enabled.json`
      : 'mkdir -p /opt/terraria/config/Worlds';
    await execRead(tempContainer.id, ['sh', '-c', mkCmd]);

    // Upload world file if importing
    if (worldMode === 'import' && worldFile) {
      const pack = tar.pack();
      const safeName = path.basename(worldFile.originalname);
      pack.entry({ name: safeName, size: worldFile.buffer.length }, worldFile.buffer, err => {
        if (!err) pack.finalize();
      });
      await tempContainer.putArchive(pack, { path: '/opt/terraria/config/Worlds' });
    }

    // Extract modpack zip if provided (tModLoader only)
    if (isTml && modpackFile) {
      const modpackModsDir = `/opt/terraria/config/ModPacks/${modpack}/Mods`;
      const directory = await unzipper.Open.buffer(modpackFile.buffer);
      for (const entry of directory.files) {
        if (entry.type !== 'File') continue;
        // Flatten all files into the Mods directory regardless of zip folder structure
        const fileName = path.basename(entry.path);
        if (!fileName || fileName.startsWith('.')) continue;
        const content = await entry.buffer();
        const pack = tar.pack();
        pack.entry({ name: fileName, size: content.length }, content, err => {
          if (!err) pack.finalize();
        });
        await tempContainer.putArchive(pack, { path: modpackModsDir });
      }
    }

    await tempContainer.stop({ t: 0 });
    await tempContainer.remove();
    tempContainer = null;

    // Build env array
    const env = [
      `WORLDNAME=${effectiveWorld}`,
      `AUTOCREATE=${worldMode === 'import' ? '1' : autocreate}`,
      `DIFFICULTY=${difficulty}`,
      `MAXPLAYERS=${maxPlayers}`,
      `PORT=${portNum}`,
    ];
    if (worldEvil) env.push(`WORLDEVIL=${worldEvil}`);
    if (seed)      env.push(`SEED=${seed}`);
    if (password)  env.push(`PASSWORD=${password}`);
    if (isTml)     env.push(`MODPACK=${modpack}`);

    // Create and start the server container
    const createOpts = {
      Image: imageName,
      name,
      Env: env,
      ExposedPorts: { [`${portNum}/tcp`]: {} },
      HostConfig: {
        PortBindings: { [`${portNum}/tcp`]: [{ HostPort: String(portNum) }] },
        Binds: [`${volumeName}:/opt/terraria/config`],
        RestartPolicy: { Name: 'unless-stopped' },
      },
    };
    if (TERRARIA_PLATFORM) createOpts.platform = TERRARIA_PLATFORM;

    const server = await docker.createContainer(createOpts);
    await server.start();

    res.json({ id: server.id, name });
  } catch (e) {
    // Best-effort cleanup on failure
    if (tempContainer) {
      await tempContainer.stop({ t: 0 }).catch(() => {});
      await tempContainer.remove().catch(() => {});
    }
    if (volumeCreated) await docker.getVolume(volumeName).remove().catch(() => {});
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/containers/:id', requireAuth, async (req, res) => {
  const deleteVolume = req.query.deleteVolume === 'true';
  try {
    const c    = docker.getContainer(req.params.id);
    const info = await c.inspect();

    if (info.State.Running) await c.stop({ t: 10 });

    // Find the GUI-managed volume before removing the container
    const guiMount = (info.Mounts || []).find(
      m => m.Type === 'volume' && (m.Name || '').startsWith('terraria-gui-')
    );

    await c.remove();

    if (deleteVolume && guiMount) {
      await docker.getVolume(guiMount.Name).remove();
    }

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── WebSocket (log streaming) ─────────────────────────────────────────

const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', ws => {
  let logStream = null;
  let tailStream = null;
  let pt = null;
  let tailPt = null;
  let tailTimer = null;

  function stopStream() {
    if (tailTimer) { clearTimeout(tailTimer); tailTimer = null; }
    if (tailPt) { tailPt.destroy(); tailPt = null; }
    if (tailStream) { tailStream.destroy(); tailStream = null; }
    if (pt) { pt.destroy(); pt = null; }
    if (logStream) { logStream.destroy(); logStream = null; }
  }

  function send(obj) {
    if (ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(obj));
  }

  async function tailFile(c, filePath) {
    const exec = await c.exec({
      Cmd: ['tail', '-f', '-n', '+1', filePath],
      AttachStdout: true,
      AttachStderr: false,
    });
    const stream = await exec.start({ hijack: true, stdin: false });
    tailStream = stream;
    const out = new PassThrough();
    tailPt = out;
    docker.modem.demuxStream(stream, out, out);
    out.on('data', chunk => send({ type: 'log', data: stripAnsi(chunk.toString()) }));
    stream.on('error', () => {});
  }

  // Find the newest log file in a directory inside the container
  async function findNewestLog(c, dir) {
    try {
      const output = await execRead(c.id, [
        'find', dir, '-maxdepth', '1', '-name', '*.log', '-type', 'f',
        '-newer', '/proc/1', // only files created after container started
      ]);
      const files = output.trim().split('\n').filter(Boolean);
      if (files.length === 0) {
        // Fallback: any log file in the dir
        const all = await execRead(c.id, ['find', dir, '-maxdepth', '1', '-name', '*.log', '-type', 'f']);
        const allFiles = all.trim().split('\n').filter(Boolean);
        return allFiles[allFiles.length - 1] || null;
      }
      return files[files.length - 1];
    } catch {
      return null;
    }
  }

  ws.on('message', async raw => {
    let msg;
    try { msg = JSON.parse(raw.toString()); } catch { return; }

    if (msg.type === 'subscribe') {
      stopStream();
      try {
        const c = docker.getContainer(msg.containerId);
        const info = await c.inspect();
        const hasTty = info.Config && info.Config.Tty;
        const isTml = (info.Config.Image || '').toLowerCase().includes('tmod');

        logStream = await c.logs({ stdout: true, stderr: true, follow: true, tail: 200 });

        const reader = new PassThrough();
        pt = reader;

        if (hasTty) {
          logStream.pipe(reader);
        } else {
          docker.modem.demuxStream(logStream, reader, reader);
        }

        reader.on('data', chunk => send({ type: 'log', data: stripAnsi(chunk.toString()) }));
        logStream.on('end', () => send({ type: 'log', data: '\n[stream ended]\n' }));
        logStream.on('error', e => send({ type: 'error', data: e.message }));

        // Both server types write game output to a log file — tail it in addition to docker logs
        const logDir = isTml
          ? '/opt/terraria/server/tModLoader-Logs'
          : '/opt/terraria/config/Logs';
        const fixedLogPath = isTml
          ? '/opt/terraria/server/tModLoader-Logs/server.log'
          : null; // vanilla log filename includes a timestamp so we must discover it

        tailTimer = setTimeout(async () => {
          tailTimer = null;
          if (tailStream !== null) return; // switched containers during wait
          try {
            const logPath = fixedLogPath || await findNewestLog(c, logDir);
            if (logPath) tailFile(c, logPath).catch(() => {});
          } catch { /* log file may not exist yet — that's fine */ }
        }, 5000);
      } catch (e) {
        send({ type: 'error', data: e.message });
      }
    }
  });

  ws.on('close', stopStream);
  ws.on('error', stopStream);
});

// ── HTTP server ───────────────────────────────────────────────────────

const server = app.listen(3000, () => {
  console.log('Terraria GUI running on http://localhost:3000');
});

server.on('upgrade', (req, socket, head) => {
  if (!validateWsToken(req)) {
    socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
    socket.destroy();
    return;
  }
  wss.handleUpgrade(req, socket, head, ws => wss.emit('connection', ws, req));
});
