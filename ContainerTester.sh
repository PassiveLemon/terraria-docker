docker kill a-terrariatester
docker rm a-terrariatester

docker run -d --name a-terrariatester -p 7777:7777/tcp -v /home/docker/Containers/Test/terraria-dockertest:/opt/terraria/config passivelemon/terraria-docker:terraria-tshock
