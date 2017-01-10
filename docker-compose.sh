#!/bin/bash

# START: VARIABLES
DEBUG=true

db_engine=mysql
db_name=db
semaphore_api_name=semaphore_api
proxy_name=proxy

http_port=80
https_port=443
# START: VARIABLES

# clean up actions if DEBUG=true
if $DEBUG
then
  docker kill $(docker ps -aq)
  docker rm $(docker ps -aq)
  docker rmi -f $(docker images $semaphore_api_name:latest -q)
  docker rmi -f $(docker images $proxy_name:latest -q)
  read -p "Continue? "
fi

# build infrastructure
# BUILD proxy from Dockerfile
docker build -t $proxy_name \
  proxy/

# BUILD semaphore from Dockerfile
docker build -t $semaphore_api_name \
  semaphore/

# RUN db container
echo "RUN db container"
read -d '' docker_output << EOF
docker run \
  -p 3306:3306 \
  -e "MYSQL_RANDOM_ROOT_PASSWORD='yes'" \
  -e "MYSQL_DATABASE=semaphore" \
  -e "MYSQL_USER=semaphore" \
  -e "MYSQL_PASSWORD=semaphore" \
  -v $(pwd)/dynamic/db:/var/lib/mysql \
  -d \
  $db_engine
EOF

db_id=$(eval $docker_output);
db_api_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $db_id)

# RUN semaphore container
echo "RUN semaphore container"
read -d '' docker_output << EOF
docker run \
  -p 3000:3000 \
  -e "SEMAPHORE_PLAYBOOK_PATH=/etc/semaphore" \
  -e "SEMAPHORE_ADMIN_EMAIL=my_email@domain.com" \
  -e "SEMAPHORE_ADMIN_PASSWORD=admin" \
  -e "SEMAPHORE_ADMIN_NAME=Default Administrator" \
  -e "SEMAPHORE_ADMIN=admin" \
  -e "SEMAPHORE_DB_USER=semaphore" \
  -e "SEMAPHORE_DB_PASS=semaphore" \
  -e "SEMAPHORE_DB_HOST=$db_name" \
  -e "SEMAPHORE_DB_PORT=3306" \
  -e "SEMAPHORE_DB=semaphore" \
  -v $(pwd)/dynamic/semaphore:/etc/semaphore \
  --add-host="$db_name:$db_api_ip" \
  -d \
  $semaphore_api_name
EOF

semaphore_api_id=$(eval $docker_output);
semaphore_api_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $semaphore_api_id)

sleep 3
# RUN proxy container
echo "RUN proxy container"
read -d '' docker_output << EOF
docker run \
  -p $https_port:443 \
  -p $http_port:80 \
  --add-host="$db_name:$db_api_ip" \
  --add-host="semaphore_api:$semaphore_api_ip" \
  -d \
  $proxy_name
EOF

proxy_id=$(eval $docker_output);

docker ps
