#!/bin/bash
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


#adiciona os shards
docker exec -it $CONTAINER_ID mongosh localhost:3000 --eval "sh.addShard(\"shard1/mongo_shard1:27017\")"
docker exec -it $CONTAINER_ID mongosh localhost:3000 --eval "sh.addShard(\"shard2/mongo_shard2:27017\")"

## cria o banco
docker exec -it $CONTAINER_ID mongosh localhost:3000 --eval "sh.enableSharding(\"populations\")"
docker exec -it $CONTAINER_ID mongosh localhost:3000 --eval "sh.shardCollection(\"populations.cities\", { \"country\": \"hashed\" })"



