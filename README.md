# [terraria-docker](https://github.com/PassiveLemon/terraria-docker)

[![Repo](https://img.shields.io/badge/Docker-Repo-007EC6?labelColor-555555&color-007EC6&logo=docker&logoColor=fff&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)
[![Pulls](https://img.shields.io/docker/pulls/passivelemon/terraria-docker?labelColor-555555&color-007EC6&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)

Unofficial Docker container for a Terraria dedicated server. Supports vanilla and modded through tModLoader.

> [!NOTE]
> This is not at all affiliated with Terraria or tModLoader. Please report issues here.

## Quick setup summary (Vanilla)
1. Setup a directory for you server files. Can be something like `/opt/TerrariaServer/`(Linux) or `C:\TerrariaServer\`(Windows).
2. Run the container: <b>(Make sure to modify any values that you need)</b>
  - ```docker run -d --name terraria -p 7777:7777/tcp -v /opt/TerrariaServer/:/opt/terraria/config/ -e WORLD=myworld passivelemon/terraria-docker:terraria-latest```
3. Setup server access.

## Quick setup summary (Modded)
1. Setup a directory for you server files. Can be something like `/opt/TerrariaServer/`(Linux) or `C:\TerrariaServer\`(Windows).
2. Add your modpack to the previous directory in the sub-directory `ModPacks/` (See step 3 further down)
3. Run the container: <b>(Make sure to modify any values that you need)</b>
  - ```docker run -d --name tmodloader1.4 -p 7777:7777/tcp -v /opt/TerrariaServer/:/opt/terraria/config/ -e MODPACK=<modpack name> -e WORLD=myworld passivelemon/terraria-docker:tmodloader-latest```
4. Setup server access.

# 1. Setting up main server files
Depending on your host, find a suitable place to store your server files. Make sure it is empty, safe, and accessible. For example: On Windows, something like `C:\TerrariaServer\` or a Linux equivalent like `/opt/TerrariaServer/`.

> [!NOTE]
> For the sake of instruction, we will call this place `<config_dir>`. Any field wrapped in angle brackets is a field that needs to be substituted.

In `<config_dir>`, make one directory called `Worlds`, spelled exactly as show, and `Modpacks` if you are using tModLoader. This location is also where your `serverconfig.txt` will be stored if you want to use your own. Details on this are in step 4.

# 2. Server environment variables
For every variable you want the server to use, add that variable to your docker run or compose with `-e <variable>=<value>`. If not set, they will use their default value.

By default, modded servers will not successfully run because they need a defined modpack.

Server configuration details on the [Terraria Wiki](https://terraria.wiki.gg/wiki/Server#Server_config_file).

### Container variables
| Variable | Options | Default | Details
|:-|:-|:-|:-|
SERVERCONFIG | `boolean` | `0` | Toggles whether the server will use a user provided serverconfig file. `0` to use environment variables and `1` for provided file.

### Server variables
| Variable | Options | Default | Details |
|:-|:-|:-|:-|
| `AUTOCREATE` | `1` `2` `3`| `2` | The world size to autocreate if the worldname is not found. |
| `BANLIST` | `string`| `banlist.txt` | The file with the list of banned players. |
| `DIFFICULTY` | `0` `1` `2` `3` | `0` | The difficulty level to use with autocreate. |
| `LANGUAGE` | `en-US` `de-DE` `it-IT` `fr-FR` `es-ES` `ru-RU` `zh-Hans` `pt-BR` `pl-PL` | `en-US` | The language to use. |
| `MAXPLAYERS` | `integer` | `8` | The maximum amount of players that can be on the server. |
| `MODPACK` | `string` | `NA` | The modpack to start the server with. This only works with tModLoader. |
| `MOTD` | `string` | `NA` | The message of the day. |
| `NPCSTREAM` | `integer 0-60` | `15` | Helps with entity skipping. |
| `PASSWORD` | `string` | `NA` | The password required to join the server. |
| `PORT` | `integer` | `7777` | The port to join the server. |
| `PRIORITY` | `0` `1` `2` `3` `4` `5` | `1` | Server process priority. |
| `SECURE` | `boolean` | `1` | Cheat protection. |
| `SEED` | `string` | `NA` | The seed to use with autocreate. |
| `UPNP` | `boolean` | `0` | Automatically forward ports with uPNP. |
| `WORLDNAME` | `string` | `World` | The name of the world. This determines which world file to load. |

#### Journey Mode
All Journey Mode variables have the same options. The default is `2`.

| Variable | Options | Default |
|:-|:-|:-|
| `BIOMESPREAD_SETFROZEN` | `0` `1` `2` | `2` |
| `GODMODE` |
| `INCREASEPLACEMENTRANGE` |
| `RAIN_SETFROZEN` |
| `RAIN_SETSTRENGTH` |
| `SETDIFFICULTY` |
| `SETSPAWNRATE` |
| `TIME_SETDAWN` |
| `TIME_SETDUSK` |
| `TIME_SETFROZEN` |
| `TIME_SETMIDNIGHT` |
| `TIME_SETNOON` |
| `TIME_SETSPEED` |
| `WIND_SETFROZEN` |
| `WIND_SETSTRENGTH` |

# 3. Modpacks
<b>If you are not using tModLoader, then skip this step.</b>

Ideally, you shouldn't include any client side only mods in the modpack folder for the server. Client side mods only affect the client (player) meaning they add zero new functionality to the game. Includes things like different textures, shaders, RPC, etc. Nothing bad should happen if you do but it's just best practice. Mods are included in the modpack folder so they do not need to be obtained manually.

1. In tModLoader on a client, enable any mods that you want to play with.
2. Go to the mod pack section.
3. "Save Enabled as New Mod Pack"
4. "Open Mod Pack folder"
5. Copy the folder of the modpack you want to use in the server and paste that into `<config_dir>/ModPacks/`

Make sure the modpack has an `enabled.json` with the mods you want or else the server will not start.

# 4. Worlds
<b>If you want to continue on an existing world, follow this step. Otherwise, just skip it. The server will generate a new world automatically.</b>

If you provide a world file and correctly set the `WORLDNAME` variable, it will use the existing world.
If using tModLoader, make sure this world is always loaded with the same modpack or you may encounter world corruption.

1. Find your world file:
  - Vanilla worlds can be found at `C:\Users\<user>\Documents\My Games\Terraria\Worlds\` or the Linux equivalent, usually `/home/<user>/.local/share/Terraria/Worlds/`.
  - Modded worlds can be found at `C:\Users\<user>\Documents\My Games\Terraria\tModLoader\Worlds\` or the Linux equivalent, usually `/home/<user>/.local/share/Terraria/tModLoader/Worlds/`.
2. Copy the files of the world of your choice to `<config_dir>/Worlds/`. The world files look like `.wld` and, if using tModLoader, `.twld`.

# 5. Server config
<b>If you want to use your own server config, follow this step. Otherwise, just skip it. The server will generate a config automatically based on your provided environment variables. </b>

The root of the terraria server files in the container is `/opt/terraria/server/` and user items in `<config_dir>` are mounted at `/opt/terraria/config/`

1. Set `SERVERCONFIG` to 1.
2. Put the `serverconfig.txt` into `<config_dir>`.

Server configuration details on the [Terraria Wiki](https://terraria.wiki.gg/wiki/Server#Server_config_file).

# 6. Docker container
| Tag | Details |
|:-|:-|
| `latest` | Same as `terraria-latest`. |
| `terraria-latest` | Latest official Terraria release. |
| `terraria-<version>` | Specific version of Terraria. |
| `tmodloader-latest` | Latest tModLoader release (stable). |
| `tmodloader-latest-pre` | Latest tModLoader pre-release (unstable). |
| `tmodloader-2024` | Latest tModLoader 2024 (1.4.4) release (stable). |
| `tmodloader-2024-pre` | Latest tModLoader 2024 (1.4.4) pre-release (unstable). |
| `tmodloader-<version>` | Specific version of tModLoader. |

It is recommended to pin a tModLoader server to either a specific version or a year release tag as tModLoader can be unstable.

Terraria versions at [releases](https://github.com/PassiveLemon/terraria-docker/releases/).
tModLoader versions at [tModLoader](https://github.com/tModLoader/tModLoader/releases/) (Do not include the `v` prefix).

### Docker run
```
docker run -d --name <container name> -p 7777:7777 -v <config_dir>:/opt/terraria/config/ passivelemon/terraria-docker:terraria-latest
```

### Docker Compose
```yml
services:
  terraria-docker:
    image: passivelemon/terraria-docker:terraria-latest
    container_name: terraria-docker
    ports:
        - 7777:7777
    volumes:
      - <config_dir>:/opt/terraria/config/
```

| Operator | Need | Details |
|:-|:-|:-|
| `-d` | Yes | Will run the container in the background. |
| `--name <container name>` | No | Sets the name of the container to the following string. You can change this to whatever you want. |
| `-p 7777:7777` | Yes | The default port used by the server. This translates from your host 7777 into the container 7777. <br><b>If you use a different port for your server in your serverconfig, change this.</b></br> |
| `-v <config_dir>:/opt/terraria/config` | Yes | Sets the directory that holds the configs like your worlds and serverconfig.txt. This should be the place you chose at the beginning. |
| `passivelemon/terraria-docker:terraria-latest` | Yes | The Docker image. By default, it is the latest version. |


## Examples
### Docker run
```
docker run -d --name terraria -p 7777:7777/tcp -v /opt/terrariaServer/:/opt/terraria/config/ -e WORLD=myworld passivelemon/terraria-docker:terraria-latest
```

### Docker compose
```yml
services:
  terraria-docker:
    image: passivelemon/terraria-docker:terraria-latest
    container_name: terraria-docker
    ports:
      - 7777:7777
    volumes:
      - /opt/terrariaServer/:/opt/terraria/config/
    environment:
      WORLD: 'myworld'
```

# 7. Reference
Your config directory should look something like:
```
<config_dir>\       # This gets mounted to /opt/terraria/config/ in the container.
  Logs\             # This is optional. Make sure to mount it if you want it to be populated.
  Worlds\           # Default folder needed by the server.
  Modpacks\         # Modpack directory if using tModLoader.
  serverconfig.txt  # config file needed by the server (Only if you want to use your own).
```

# 8. Access
Theres a few ways around this:
- Playing completely over LAN. If your server and players are on the same network, then you can use the local IP of the server host.

- Playing over a VPN like Tailscale, ZeroTier, or other. You can then follow the same logic as LAN.

- Playing remotely through a domain or public IP. See below.
  
Unless you plan to play completely locally or over a VPN, you will need to port forward for players outside of your network to access the server. The general idea of port forwarding is when a client sends a request to the server (with a specific port), a properly set up port forward will allow the request to go through and to the specified host. Terraria uses 7777 by default but you can change this in your config file.

If you do not have access to your network infrastructure, you will need to resort to either playing over LAN or a VPN.

1. Head to your router web interface by typing your gateway IP into your router. It might be `192.168.1.1`, `172.1.0.1` or something else. This will vary depending on how your network is setup.

2. Find the port forwarding section. Your router management software is probably going to be different but theres a good chance that its just called "port forwarding" or under a "NAT" tab or something of the likes.
EX: For PFsense, it is under NAT and is called Port Forwarding. Your inputs may also look a little different. Please consult your software manufactuerers manual for guidance if you do not know what you are doing.

3. Set the external or incoming port. This is the port that players will type when they try to join your server.

4. Set the internal or outgoing port. This is the port that will be used by Docker. This is the first part of the `-p 7777:7777`.
The second part is the container port. This is what you put into your server config (7777 by default).

5. Set your destination IP. This will be the IP of your server/host. There are many ways to find it. Go to your terminal: Windows is `ipconfig`. Most Linux distros have `ip a` or `ifconfig` or a similar command. Look for your interface, whether it is wifi or wired, and find your IPV4 address. It might look like `192.168.1.XXX` or `172.1.0.XXX`. Again, will probably be different.
  - If you do not have a static local IP address for your host, it might eventually change. If this happens, your port forwarding will no longer work. Research how to set up a static IP on your router.

6. Find your public IP address. You can go to [whatismyip](https://www.whatismyip.com/) or elsewhere and use the IPv4 address that it returns. If have a domain, you probably don't need these instructions.
  - <b>NOTE:</b> While this won't pin point your location, it can give users some geographical information.

> [!NOTE]
> Your public IP might eventually change if it is not static. You can work around this with a DDNS like DuckDNS or FreeDNS.

You will also need a port. If you didn't change the defaults, it will just be 7777. If you did change from defaults, it will be whatever port you set as your external port in your router.

More info on the [Fandom](https://terraria.fandom.com/wiki/Guide:Setting_up_a_Terraria_server#PF) and at [whatismyip.com/port-forwarding/](https://www.whatismyip.com/port-forwarding/).

# 9. The end
Assuming you did everything correctly, you should have a functional server that will automatically load the world upon start.

Have fun!

## Command injection
You can run the command `docker exec <container name> inject "<command>"` to inject a command directly into the server. An example: `docker exec terraria inject "say Hello from the server!"`

More info on the [Terraria Wiki](https://terraria.wiki.gg/wiki/Server#List_of_console_commands).

# Credits
[rfvgyhn](https://github.com/rfvgyhn/tmodloader-docker) for the server injection functionality.

