CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator-password';
SELECT pg_create_physical_replication_slot('replication_slot');