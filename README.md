# [terraria-docker](https://github.com/PassiveLemon/terraria-docker) </br>

[![Repo](https://img.shields.io/badge/Docker-Repo-007EC6?labelColor-555555&color-007EC6&logo=docker&logoColor=fff&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)
[![Version](https://img.shields.io/docker/v/passivelemon/terraria-docker/latest?labelColor-555555&color-007EC6&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)
[![Size](https://img.shields.io/docker/image-size/passivelemon/terraria-docker/latest?labelColor-555555&color-007EC6&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)
[![Pulls](https://img.shields.io/docker/pulls/passivelemon/terraria-docker?labelColor-555555&color-007EC6&style=flat-square)](https://hub.docker.com/r/passivelemon/terraria-docker)

Docker container for a Terraria dedicated server

Setup guide is also in the [Wiki](https://github.com/PassiveLemon/terraria-docker/wiki) for organization. </br>

# Quick setup
1. Setup a directory for you server files. Can be something like `/opt/TerrariaServer/`(Linux) or `C:\TerrariaServer\`(Windows).
2. Run the container: <b>(Make sure to modify any values that you need.)</b>
  - ```docker run -d --name terraria -p 7777:7777/tcp -v /opt/TerrariaServer/:/opt/terraria/config/ -e WORLD=superworld passivelemon/terraria-docker:latest```
3. Set up port forwarding.

# 1. Setting up main server files
Depending on your host, find a suitable place to store your server files. Make sure it is empty, safe, and accessible. For example: On Windows, something like `C:\TerrariaServer\` or a Linux equivalent like `/opt/TerrariaServer/`. </br>

For the sake of these instructions, we will call this place `(ConfDir)`. In `(ConfDir)`, make one directory called `Worlds`, spelled exactly as show. This location is also where your `serverconfig.txt` will be stored if you want to use your own. Details on this are in step 4. </br>

# 2. Server environment variables
For every variable you want the server to use, add that variable to your docker run or compose with `-e (Variable)=(Value)`. If they are not set, they will default to whatever their default value is. This is to ensure basic functionality. By default, the server will not successfully run.

### Container variables </br>
| Variable | Options | Default | Details
|:-|:-|:-|:-|
SERVERCONFIG | `boolean` | `0` | Toggles whether the server will use a user provided serverconfig file. `0` to use environment variables and `1` for provided file.

Check out server details and examples [here on the wiki](https://terraria.wiki.gg/wiki/Server#Command-line_parameters). </br>

### Server variables </br>
| Variable | Options | Default |
|:-|:-|:-|
AUTOCREATE | `1` `2` `3`| `2`
DIFFICULTY | `0` `1` `2` `3` | `0`
BANLIST | `string`| `banlist.txt`
LANGUAGE | `en-US` `de-DE` `it-IT` `fr-FR` `es-ES` `ru-RU` `zh-Hans` `pt-BR` `pl-PL` | `en-US`
MAXPLAYERS | `integer` | `8`
MOTD | `string` | `NA`
NPCSTREAM | `integer 0-60` | `15`
PASSWORD | `string` | `NA`
PORT | `integer` | `7777`
PRIORITY | `0` `1` `2` `3` `4` `5` | `1`
SECURE | `boolean` | `1`
SEED | `string` | `NA`
UPNP | `boolean` | `0`
WORLDNAME | `string` | `World`

Journey mode variables are not supported in the Dockerfile variable statements. Those will need to be manually put in the server config. </br>

<br> Boolean values are either on (1) or off (0). </br>
<br> Strings are anything you want to put in it, as long as it is valid. </br>
<br> Numbers are simply just numbers with no spaces. These too have a functional limit. </br>

# 3. Worlds
<b> If you want to continue on an existing world, follow this step. Otherwise, just skip it. The server will generate a new world automatically.</b>

If you provide a world file and correctly set the `WORLDNAME` variable, it will use the existing world. </br>

1. Go to `C:\Users\(user)\Documents\My Games\Terraria\Worlds\` or the Linux equivalent, usually `/home/(user)/.local/share/Terraria/Worlds/`. </br>
2. Copy the files of the world of your choice to `(ConfDir)/Worlds/`. The world files look like `.wld`. </br>

# 4. Server config
<b> If you want to use your own server config, follow this step. Otherwise, just skip it. The server will generate a config automatically based on your provided environment variables. </b>

The root of the terraria server files in the container is `/opt/terraria/server/` and user items in `(ConfDir)` are mounted at `/opt/terraria/config/` </br>

1. Set `SERVERCONFIG` to 1.
2. Put the `serverconfig.txt` into `(ConfDir)/`.

[Server configuration details on the Terraria Wiki](https://terraria.wiki.gg/wiki/Server#Command-line_parameters) </br>

# 6. Docker container
### Docker run </br>
```
docker run -d --name (container name) -p 7777:7777 -v (ConfDir):/opt/terraria/config/ passivelemon/terraria-docker:latest
```

### Docker Compose
```yml
version: '3.3'
services:
  terraria-docker:
    image: passivelemon/terraria-docker:latest
    container_name: terraria-docker
    ports:
        - 7777:7777
    volumes:
      - (configuration directory):/opt/terraria/config/
```

| Operator | Need | Details |
|:-|:-|:-|
| `-d` | Yes | Will run the container in the background. |
| `--name (container name)` | No | Sets the name of the container to the following string. You can change this to whatever you want. |
| `-p 7777:7777` | Yes | The default port used by the server. This translates from your host 7777 into the container 7777. <br><b>If you use a different port for your server in your serverconfig, change this.</b></br> |
| `-v (ConfDir):/opt/terraria/config` | Yes | Sets the folder that holds the configs like your worlds and serverconfig.txt. This should be the place you just chose. |
| `passivelemon/terraria-docker:latest` | Yes | The repository on Docker hub. By default, it is the latest version that I have published. |


## Examples </br>
### Docker run
```
docker run -d --name terraria -p 7777:7777/tcp -v /opt/terrariaServer/:/opt/terraria/config/ -e WORLD=superworld passivelemon/terraria-docker:latest
```

### Docker compose
```yml
version: '3.3'
services:
  terraria-docker:
    image: passivelemon/terraria-docker:latest
    container_name: terraria-docker
    ports:
      - 7777:7777
    volumes:
      - /opt/terrariaServer/:/opt/terraria/config/
    environment:
      WORLD: 'superworld'
```

# 7. Port forwarding
Unless you have some special case, you will need to port forward. The general idea of port forwarding is when a client sends a request to the server (with a specific port), a properly port forwarded router will allow the request to go through and to the specified host. Terraria uses 7777 by default but you can change this in your config file. </br>

1. Head to your router web interface by typing your gateway IP into your router. (If you do not know this, you should probably figure it out.) It might be `192.168.1.1` or `172.1.0.1` or something of the likes. This will vary depending on how your network is setup.

2. Find the port forwarding section. Your router management software is probably going to be different but theres a good chance that its just called "port forwarding" or under a "NAT" tab or something of the likes. </br>
EX: For PFsense, it is under NAT and is called Port Forwarding. Your inputs may also look a little different. Please consult your software manufactuerers manual for guidance if you do not know what you are doing. </br>

3. Set the external or incoming port. This is the port that players will type when they try to join your server. </br>

4. Set the internal or outgoing port. This is the port that will be used by Docker. This is the first part of the `-p 7777:7777`. </br>
The second part is the container port. This is what you put into your server config (7777 by default). </br>

5. Set your destination IP. This will be the IP of your server/host. There are many ways to find it. Go to your terminal: Windows is `ipconfig`. Most Linux use `ip a` or a similar command. Look for your interface, whether it is wifi or wired, and find your IPV4 address. It might look like `192.168.1.XXX` or `172.1.0.XXX`. Again, will probably be different. </br>
    - <b>NOTE:</b> Your server/host IP might eventually change. If this happens, your port forwarding will no longer work. You will need to set a static IP address. Research how to do this. </br>

[More info on the Terraria Wiki](https://terraria.fandom.com/wiki/Guide:Setting_up_a_Terraria_server#PF) </br>

# 8. Reference
Your config directory should look something like:
```
(ConfDir)\              - This gets mounted to /config/ in the container
    Logs\               - This is optional. Make sure to mount it.
    Worlds\             - Default folder needed by the server
    serverconfig.txt    - config file needed by the server (Only if you want to use your own)
```

# 9. The end
Assuming you did everything correctly, you should have a functional server that will automatically load the world upon start.</br>

## Command injection
You can run the command `docker exec (container name or id) inject "phrase"` to inject a phrase or command directly into the server. An example: `docker exec terraria inject "say I'm radioactive!"`

## Access </br>
In order to access the server, you will need the public IP of the host. This could be access from a properly setup CDN but you might not have one. In this case, search up "Whats my ip" or similar into your browser and use the IP that it shows.
- <b>NOTE:</b> It isn't recommended to use this as it gives users your general location. It may be the only option you have though so be careful. </br>

You will also need a port. If you didn't change the defaults, it will just be 7777. If you did change from defaults, it will be whatever port you set as your external port in your router. </br>

Have fun! </br>

# Credits
[rfvgyhn](https://github.com/rfvgyhn/tmodloader-docker) for the server injection functionality.

