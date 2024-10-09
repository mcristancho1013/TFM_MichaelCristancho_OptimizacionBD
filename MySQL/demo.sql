CREATE DEFINER=`root`@`localhost` PROCEDURE `turnosdb`.`demo`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE office VARCHAR(100);
  DECLARE cur1 CURSOR FOR SELECT Oficina FROM turnosdb.oficinas WHERE Oficina <> 'Prueba';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO office;
    IF done THEN
      LEAVE read_loop;
    END IF;
    INSERT parametro_plasma SELECT office, Archivo, Parametro, Valor FROM parametro_plasma WHERE Oficina = 'Prueba';
  END LOOP;

  CLOSE cur1;
END;