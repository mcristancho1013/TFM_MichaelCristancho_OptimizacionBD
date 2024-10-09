CREATE DEFINER=`root`@`localhost` PROCEDURE `turnosdb`.`limpieza`()
BEGIN
DECLARE P_Id DECIMAL(16, 0);

SET P_Id = DATE(SYSDATE()) * 1000000;
UPDATE turnosdb.regtransac SET EstadoTurno = 5 WHERE Id > P_Id AND TIMESTAMPDIFF (SECOND, HoraLLamado, HoraFinAtencion) > 7200 AND EstadoTurno <> 0;
UPDATE turnosdb.regtransac set EstadoTurno = 5 WHERE Id > P_Id AND HoraFinAtencion = '2001-01-01 00:00:00' AND EstadoTurno = 3;
UPDATE turnosdb.regtransac SET EstadoTurno = 5 WHERE Id > P_Id AND TIMESTAMPDIFF (SECOND, HoraLLamado, NOW()) > 7200 AND EstadoTurno = 2;
DELETE FROM turnosdb.regtransac WHERE Id > P_Id AND HoraFinAtencion < HoraLLamado AND EstadoTurno = 3;
end;