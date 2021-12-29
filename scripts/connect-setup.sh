echo "Creating Postgres Sink connector"
curl -s -X PUT -H  "Content-Type:application/json" http://localhost:8083/connectors/sink-postgres-orders_01/config \
     -d '{
               "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
               "tasks.max": "3",
               "connection.url": "jdbc:postgresql://postgres:5432/testdb",
               "connection.user": "superdbuser",
               "connection.password": "changeit",
               "auto.create": "true",
               "insert.mode": "upsert",
               "topics": "orders",
               "pk.mode": "record_value",
               "pk.fields": "order_id"
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
               "database.server.name": "digitalassets",
               "database.history.kafka.bootstrap.servers": "broker:29092",
               "database.history.kafka.topic": "schema-changes.pg",
               "plugin.name": "pgoutput",
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
