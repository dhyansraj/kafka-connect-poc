echo "Creating Postgres Sink connector"
curl -s -X PUT -H  "Content-Type:application/json" http://localhost:8083/connectors/sink-postgres-orders_01/config \
     -d '{
               "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
               "tasks.max": "3",
               "connection.url": "jdbc:postgresql://postgres:5432/testdb?options=-c%20search_path=digitalassets,public",
               "connection.user": "superdbuser",
               "connection.password": "changeit",
               "auto.create": "false",
               "insert.mode": "insert",
               "topics": "orders",
               "pk.mode": "none",
               "fields.whitelist": "customer_id,supplier_id,first_name,last_name,items,price,weight,automated_email"
            }'

echo "Creating Postgres CDC connector"

curl -i -X PUT -H "Accept:application/json" \
     -H  "Content-Type:application/json" http://localhost:8083/connectors/source-debezium-postgres-orders-01/config \
     -d '{
               "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
               "tasks.max": "1",
               "database.hostname": "postgres",
               "database.port": "5432",
               "database.dbname" : "testdb",
               "database.user": "superdbuser",
               "database.password": "changeit",
               "database.server.name": "seione",
               "database.history.kafka.bootstrap.servers": "broker:29092",
               "database.history.kafka.topic": "schema-changes.pg",
               "plugin.name": "pgoutput",
               "table.include.list": "digitalassets.orders",
               "transforms": "unwrap,InsertTopic,InsertSourceDetails",
               "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
               "transforms.unwrap.drop.tombstones": "false",
               "transforms.unwrap.delete.handling.mode": "rewrite",
               "transforms.unwrap.add.fields": "table,lsn",
               "transforms.InsertTopic.type":"org.apache.kafka.connect.transforms.InsertField$Value",
               "transforms.InsertTopic.topic.field":"messagetopic",
               "transforms.InsertSourceDetails.type":"org.apache.kafka.connect.transforms.InsertField$Value",
               "transforms.InsertSourceDetails.static.field":"messagesource",
               "transforms.InsertSourceDetails.static.value":"Debezium CDC from Postgres on Orders"
            }'

echo "Creating Mongo Sink Connector"

curl -i -X PUT -H "Accept:application/json" \
     -H  "Content-Type:application/json" http://localhost:8083/connectors/sink-mongo-orders-01/config \
     -d '{
               "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
               "tasks.max": "1",
               "topics":"seione.digitalassets.orders",
               "connection.uri":"mongodb://da_user:passwd@mongo:27017",
               "database":"digitalassets",
               "collection":"orders",
               "key.converter":"io.confluent.connect.avro.AvroConverter",
               "key.converter.schema.registry.url":"http://schema-registry:8081",
               "value.converter":"io.confluent.connect.avro.AvroConverter",
               "value.converter.schema.registry.url":"http://schema-registry:8081"
            }'
