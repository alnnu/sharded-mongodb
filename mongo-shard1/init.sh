#!/bin/bash

docker compose up -d

CONTAINER_ID=$(docker compose ps -q)
echo "ID do Container: $CONTAINER_ID"

# Esperar até que o Mongo esteja pronto
echo "Aguardando MongoDB iniciar..."

# Esse loop tenta conectar no Mongo até dar certo
until docker exec $CONTAINER_ID mongosh --eval "db.runCommand({ ping: 1 })"; do
    echo "MongoDB não está pronto ainda... tentando novamente em 2 segundos..."
    sleep 2
done

echo "MongoDB pronto! Conectando..."

docker exec -it $CONTAINER_ID mongosh --eval "rs.initiate({_id: \"shard1\",members: [{ _id : 0, host : \"mongo_shard1:27017\" },]})"

