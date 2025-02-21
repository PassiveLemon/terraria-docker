#!/usr/bin/env bash

declare -A VAR_ARRAY

# Define server variables for config pasting later. Very crude and ugly
VAR_ARRAY[AUTOCREATEx]="autocreate=${AUTOCREATE}"
VAR_ARRAY[DIFFICULTYx]="difficulty=${DIFFICULTY}"
VAR_ARRAY[BANLISTx]="banlist=${BANLIST}"
VAR_ARRAY[LANGUAGEx]="language=${LANGUAGE}"
VAR_ARRAY[MAXPLAYERSx]="maxplayers=${MAXPLAYERS}"
if [ "$MOTD" != "" ]; then
  VAR_ARRAY[MOTDx]="motd=${MOTD}"
fi
VAR_ARRAY[NPCSTREAMx]="npcstream=${NPCSTREAM}"
if [ "$PASSWORD" != "" ]; then
  VAR_ARRAY[PASSWORDx]="password=${PASSWORD}"
fi
if [ "$PORT" != "" ]; then
  VAR_ARRAY[PORTx]="port=${PORT}"
fi
VAR_ARRAY[PRIORITYx]="priority=${PRIORITY}"
VAR_ARRAY[SECUREx]="secure=${SECURE}"
if [ "$SEED" != "" ]; then
  VAR_ARRAY[SEEDx]="seed=${SEED}"
fi
VAR_ARRAY[UPNPx]="upnp=${UPNP}"
VAR_ARRAY[WORLDNAMEx]="worldname=${WORLDNAME}"

# Journey mode
VAR_ARRAY[BIOMESPREAD_SETFROZENx]="journeypermission_biomespread_setfrozen=${BIOMESPREAD_SETFROZEN}"
VAR_ARRAY[GODMODEx]="journeypermission_godmode=${GODMODE}"
VAR_ARRAY[INCREASEPLACEMENTRANGEx]="journeypermission_increaseplacementrange=${INCREASEPLACEMENTRANGE}"
VAR_ARRAY[RAIN_SETFROZENx]="journeypermission_rain_setfrozen=${RAIN_SETFROZEN}"
VAR_ARRAY[RAIN_SETSTRENGTHx]="journeypermission_rain_setstrength=${RAIN_SETSTRENGTH}"
VAR_ARRAY[SETDIFFICULTYx]="journeypermission_setdifficulty=${SETDIFFICULTY}"
VAR_ARRAY[SETSPAWNRATEx]="journeypermission_setspawnrate=${SETSPAWNRATE}"
VAR_ARRAY[TIME_SETDAWNx]="journeypermission_time_setdawn=${TIME_SETDAWN}"
VAR_ARRAY[TIME_SETDUSKx]="journeypermission_time_setdusk=${TIME_SETDUSK}"
VAR_ARRAY[TIME_SETFROZENx]="journeypermission_time_setfrozen=${TIME_SETFROZEN}"
VAR_ARRAY[TIME_SETMIDNIGHTx]="journeypermission_time_setmidnight=${TIME_SETMIDNIGHT}"
VAR_ARRAY[TIME_SETNOONx]="journeypermission_time_setnoon=${TIME_SETNOON}"
VAR_ARRAY[TIME_SETSPEEDx]="journeypermission_time_setspeed=${TIME_SETSPEED}"
VAR_ARRAY[WIND_SETFROZENx]="journeypermission_wind_setfrozen=${WIND_SETFROZEN}"
VAR_ARRAY[WIND_SETSTRENGTHx]="journeypermission_wind_setstrength=${WIND_SETSTRENGTH}"

# Automatically set variables
VAR_ARRAY[WORLDx]="world=/opt/terraria/config/Worlds/${WORLDNAME}.wld"

# Write variables to file
if [ "$SERVERCONFIG" = "0" ]; then
  if [ -e "/opt/terraria/config/serverconfig.txt" ]; then
    rm /opt/terraria/config/serverconfig.txt
  fi
  for argument in "${VAR_ARRAY[@]}"; do
    echo "$argument" >> /opt/terraria/config/serverconfig.txt
  done
fi

