net start

docker images

docker ps -a

docker stop D:\Repos
docker rm 2b11aa8d145a


docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" Bison2