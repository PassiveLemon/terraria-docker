#!/usr/bin/env python3

import os
import sys

def getenv(key, default=""):
  return os.environ.get(key, default)

config = {
  # Image
  "vanilla": getenv("VANILLA", "true") != "false",
  "version": getenv("VERSION"),
  "serverconfig": getenv("SERVERCONFIG", "0") == "0",
  
  # General
  "autocreatex": getenv("AUTOCREATE", "2"), # An alternate autocreate implementation is used due to issues with the default
  "banlist": getenv("BANLIST", "banlist.txt"),
  "difficulty": getenv("DIFFICULTY", "1"),
  "language": getenv("LANGUAGE", "en-US"),
  "maxplayers": getenv("MAXPLAYERS", "8"),
  "modpackname": getenv("MODPACK"), # Custom
  "motd": getenv("MOTD"),
  "npcstream": getenv("NPCSTREAM", "15"),
  "password": getenv("PASSWORD"),
  "port": getenv("PORT", "7777"),
  "priority": getenv("PRIORITY", "1"),
  "secure": getenv("SECURE", "1"),
  "seed": getenv("SEED"),
  "upnp": getenv("UPNP", "0"),
  "worldevil": getenv("WORLDEVIL", "1"), # Custom
  "worldname": getenv("WORLDNAME", "World"),

  # Journey mode
  "journeypermission_biomespread_setfrozen": getenv("BIOMESPREAD_SETFROZEN", "2"),
  "journeypermission_godmode": getenv("GODMODE", "2"),
  "journeypermission_increaseplacementrange": getenv("INCREASEPLACEMENTRANGE", "2"),
  "journeypermission_rain_setfrozen": getenv("RAIN_SETFROZEN", "2"),
  "journeypermission_rain_setstrength": getenv("RAIN_SETSTRENGTH", "2"),
  "journeypermission_setdifficulty": getenv("SETDIFFICULTY", "2"),
  "journeypermission_setspawnrate": getenv("SETSPAWNRATE", "2"),
  "journeypermission_time_setdawn": getenv("TIME_SETDAWN", "2"),
  "journeypermission_time_setdusk": getenv("TIME_SETDUSK", "2"),
  "journeypermission_time_setfrozen": getenv("TIME_SETFROZEN", "2"),
  "journeypermission_time_setmidnight": getenv("TIME_SETMIDNIGHT", "2"),
  "journeypermission_time_setnoon": getenv("TIME_SETNOON", "2"),
  "journeypermission_time_setspeed": getenv("TIME_SETSPEED", "2"),
  "journeypermission_wind_setfrozen": getenv("WIND_SETFROZEN", "2"),
  "journeypermission_wind_setstrength": getenv("WIND_SETSTRENGTH", "2"),
}

if (not config["vanilla"]) and (config["modpackname"] == ""):
  print("Modpack name was not provided. Env MODPACK must be set.")
  sys.exit(1)

# Automatic
config["modpack"] = f"/opt/terraria/config/ModPacks/{config["modpackname"]}/Mods/enabled.json"
config["modpath"] = f"/opt/terraria/config/ModPacks/{config["modpackname"]}/Mods/"
config["world"] = f"/opt/terraria/config/Worlds/{config["worldname"]}.wld"

