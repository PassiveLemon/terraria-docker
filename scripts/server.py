#!/usr/bin/env python3

import os
import signal
import shutil
import subprocess
import sys
import time

import pexpect

from variables import config

server_proc = None
server_path = "/opt/terraria/server"
config_path = "/opt/terraria/config"

def command(command):
  if server_proc and server_proc.stdin:
    server_proc.stdin.write(f"{command}\n")
    server_proc.stdin.flush()

def cleanup(_signum, _handler):
  if server_proc:
    command("say Shutting down server in 5 seconds...")
    time.sleep(5)
    command("exit")
    # Wait for successful exit if possible
    while server_proc.poll() is None:
      time.sleep(0.5)
  sys.exit(0)

def configure():
  if config["serverconfig"]:
    with open(f"{config_path}/serverconfig.txt", "w") as f:
      for k, v in config.items():
        if v != "":
          f.write(f"{k}={v}\n")
    shutil.copyfile(f"{config_path}/serverconfig.txt", f"{server_path}/serverconfig.txt")

# Custom autocreate implementation due to issues with normal autocreate:
# Autocreate can cause weird visual world corruption: https://forums.terraria.org/index.php?threads/world-breaks-for-dedicated-servers-if-autocreate-config-option-is-set-incorrectly.146226/
# Cannot define a world evil
# If/when these get fixed, this implementation would no longer be needed.
def autocreate(args, world_path):
  # Wipe the Terraria share path to clear stale files
  share_path = "/home/terraria/.local/share/Terraria/"
  if os.path.exists(share_path):
    shutil.rmtree(share_path)
  if not os.path.isfile(f"{world_path}/{config["worldname"]}.wld"):
    print("World not found, generating...")
    p = pexpect.spawn(args[0], [ "-server", "-nosteam" ], encoding="utf-8", cwd=server_path)
    p.logfile = sys.stdout
    p.expect("Choose World:")
    p.sendline("n")
    p.expect("Choose size:")
    p.sendline(config["autocreatex"])
    p.expect("Choose difficulty:")
    p.sendline(config["difficulty"])
    p.expect("Choose world evil:")
    p.sendline(config["worldevil"])
    p.expect("Enter world name:")
    p.sendline(config["worldname"])
    p.expect_exact("Enter Seed (Leave Blank For Random):")
    p.sendline(config["seed"])
    if config["vanilla"]:
      p.expect_exact("Enter Seed Number to enable/disable it (Leave Blank To Continue):")
      p.sendline("")
    p.expect("Choose World:") # Detect finish
    print("World generated.")
    p.sendcontrol("c")
    p.expect(pexpect.EOF)
    p.close()
    return True
  return False

def start_terraria():
  print(f"Terraria Version: {config["version"]}")
  server_args = [
    f"{server_path}/TerrariaServer",
    "-config",
    f"{server_path}/serverconfig.txt",
  ]
  world_path = f"{config_path}/Worlds"
  gen = autocreate(server_args, world_path)
  if gen:
    shutil.copytree(f"/home/terraria/.local/share/Terraria/Worlds", world_path, dirs_exist_ok=True)
  return subprocess.Popen(server_args, stdin=subprocess.PIPE, text=True, cwd=server_path)

def start_tmodloader():
  tmlver = config["version"]
  print(f"tModLoader Version: {tmlver}")
  # Check that the modpack version matches tml if tmlversion.txt is present
  modpack_tmlver_file = f"{config_path}/ModPacks/{config["modpackname"]}/Mods/tmlversion.txt"
  if os.path.isfile(modpack_tmlver_file):
    f = open(modpack_tmlver_file, "r")
    modpack_tmlver = f.read()
    f.close()
    print(f"Modpack TML Version: {modpack_tmlver}")
    if modpack_tmlver != tmlver:
      print(f"Warning: Modpack TML version ({modpack_tmlver}) does not match tModLoader version ({tmlver})")
  else:
    print("Warning: Modpack tmlversion.txt not found, unable to check compatability.")
  server_args = [
    f"{server_path}/LaunchUtils/ScriptCaller.sh",
    "-server",
    "-nosteam",
    "-tmlsavedirectory",
    config_path,
    "-config",
    f"{server_path}/serverconfig.txt",
  ]
  world_path = f"{config_path}/Worlds"
  gen = autocreate(server_args, world_path)
  if gen:
    shutil.copytree(f"/home/terraria/.local/share/Terraria/tModLoader/Worlds", world_path, dirs_exist_ok=True)
  return subprocess.Popen(server_args, stdin=subprocess.PIPE, text=True, cwd=server_path)

def main():
  signal.signal(signal.SIGTERM, cleanup)

  configure()

  global server_proc
  if config["vanilla"]:
    server_proc = start_terraria()
  else:
    server_proc = start_tmodloader()
  
  command("help")

  # Read python input stream and send inputs to the server
  for line in sys.stdin:
    command(line)

main()

