net start

docker images

docker pull "mcr.microsoft.com/businesscentral/onprem:16.3.14085.14238-na"

docker ps -a

docker stop D:\Repos
docker rm 2b11aa8d145a



docker build https://hub.docker.com/_/microsoft-businesscentral-sandbox

docker save -o "D:\Containers\me.rar" d2f7e1a146ab


docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" Bison2