CREATE EVENT truncateTableros
ON SCHEDULE EVERY 24 HOUR
STARTS '2024-05-04 21:00:00.000'
ON COMPLETION PRESERVE
ENABLE
DO BEGIN
TRUNCATE turnosdb.ttableros;
END;