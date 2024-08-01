#!/usr/bin/env bash

# Define server variables for config pasting later. Very crude and ugly
AUTOCREATEx="autocreate=${AUTOCREATE}"
DIFFICULTYx="difficulty=${DIFFICULTY}"
BANLISTx="banlist=${BANLIST}"
LANGUAGEx="language=${LANGUAGE}"
MAXPLAYERSx="maxplayers=${MAXPLAYERS}"
if [ "$MOTD" != "" ]; then
  MOTDx="motd=${MOTD}"
fi
NPCSTREAMx="npcstream=${NPCSTREAM}"
if [ "$PASSWORD" != "" ]; then
  PASSWORDx="password=${PASSWORD}"
fi
PORTx="port=7777"
PRIORITYx="priority=${PRIORITY}"
SECUREx="secure=${SECURE}"
if [ "$SEED" != "" ]; then
  SEEDx="seed=${SEED}"
fi
UPNPx="upnp=${UPNP}"
WORLDNAMEx="worldname=${WORLDNAME}"

# Automatically set variables
WORLDx="world=/opt/terraria/config/Worlds/${WORLDNAME}.wld"

# Write variables to file
cd /opt/terraria/config/
if [ "$SERVERCONFIG" = "0" ]; then
  if [ -e "/opt/terraria/config/serverconfig.txt" ]; then
    rm /opt/terraria/config/serverconfig.txt
  fi
  for argument in $AUTOCREATEx $DIFFICULTYx $BANLISTx $LANGUAGEx $MAXPLAYERSx $MOTDx $NPCSTREAMx $PASSWORDx $PORTx $PRIORITYx $SEEDx $SECUREx $UPNPx $WORLDNAMEx $WORLDx; do
    echo $argument >> serverconfig.txt
  done
fi
