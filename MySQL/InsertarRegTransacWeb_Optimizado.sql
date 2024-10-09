CREATE DEFINER=`admin`@`%` PROCEDURE `turnosdb`.`insertarRegTransacWeb`(
  IN A_HoraPeticion VARCHAR(255),
  IN P_TipoServicio int(11),
  OUT P_Turno int(11),
  IN A_HoraInicioAtencion VARCHAR(255),
  IN A_HoraLLamado VARCHAR(255),
  IN A_HoraFinAtencion VARCHAR(255),
  IN P_EstadoTurno int(11),
  IN P_Sesion int(11),
  IN P_Subservicio int(11),
  IN P_Subservicio1 int(11),
  IN P_Subservicio2 int(11),
  IN P_Subservicio3 int(11),
  IN P_Subservicio4 int(11),
  IN P_NombreCliente varchar(100),
  IN P_TipoDocumento varchar(45),
  IN P_Documento varchar(45),
  IN P_IdSala int(10),
  IN P_Cedula varchar(45),
  IN P_oficina varchar(20),
  IN P_Prefijo varchar(45),
  IN P_IdColaServicio int(11),
  OUT P_Id decimal(16),
  IN P_DIRECCION_IP varchar(100),
  IN P_USUARIO varchar(100)
)
begin

DECLARE P_HoraPeticion datetime;
DECLARE P_HoraInicioAtencion datetime;
DECLARE P_HoraLLamado datetime;
DECLARE P_HoraFinAtencion datetime;
  
DECLARE P_MaxTurno int;
DECLARE P_Dia DATE;
DECLARE P_dDia DATETIME;
DECLARE P_Cont int;
DECLARE P_MinFechaCS DATETIME;
DECLARE P_IdCampo int;
DECLARE P_Valor varchar(100);
DECLARE exit_loop BOOLEAN;
DECLARE P_IdFuncionario int;
DECLARE P_Descripcion varchar(30);
DECLARE P_FechaEspera DATETIME;

DECLARE iNumeroMinimo int;
DECLARE iNumeroMaximo int;
DECLARE TurnoActual int;
DECLARE iTurAct int;
DECLARE vValor varchar(255);
DECLARE P_Id_TRUNC decimal(16);
DECLARE P_ID_ULT decimal(16);

DECLARE C_CS CURSOR FOR SELECT IdCampo, Valor FROM cola_servicio WHERE IdServicio = P_TipoServicio AND Id = P_IdColaServicio;
DECLARE C_MU CURSOR FOR
	SELECT DISTINCT F.IdFuncionarios, TS.Descripcion, F.FechaEspera
	FROM tfuncionarios F
		INNER JOIN tsesion S ON F.oficina = S.oficina AND F.IdFuncionarios = S.IdFuncionario
		INNER JOIN tpuntos P ON P.oficina = S.oficina AND P.NumeroPunto = S.Caja
		INNER JOIN tservicios TS ON TS.oficina = P.oficina AND TS.Id = P.Servicio
	WHERE F.oficina = P_oficina
		AND F.DisparaTurno = 'S'
		AND S.HoraReady >= CURDATE()
		AND (S.HoraFueraServicio IS NULL OR YEAR(S.HoraFueraServicio) = 1 OR YEAR(S.HoraFueraServicio) = 2001 OR YEAR(S.HoraFueraServicio) = 1901)
		AND P.Servicio = P_TipoServicio
	ORDER BY F.FechaEspera;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;

	/*SET P_HoraPeticion = STR_TO_DATE(A_HoraPeticion, '%d/%m/%Y %T');*/
	SET P_HoraPeticion = SYSDATE();
	SET P_HoraInicioAtencion = STR_TO_DATE(A_HoraInicioAtencion, '%d/%m/%Y %T');
	SET P_HoraLLamado = STR_TO_DATE(A_HoraLLamado, '%d/%m/%Y %T');
	SET P_HoraFinAtencion = STR_TO_DATE(A_HoraFinAtencion, '%d/%m/%Y %T');

	SET P_Id_TRUNC = concat(DATE(P_HoraPeticion) + 0, '000000') + 0;
	
	SELECT NumeroMinimo, NumeroMaximo, TurnoActual INTO iNumeroMinimo, iNumeroMaximo, TurnoActual FROM tservicios WHERE oficina = P_oficina and Id = P_TipoServicio;

	SELECT IFNULL(MAX(Turno), 0)
	INTO iTurAct
	FROM regtransac_hoy
	WHERE oficina = P_oficina
		and TipoServicio = P_TipoServicio
		and HoraPeticion = (
			SELECT MAX(HoraPeticion)
			FROM regtransac_hoy
			WHERE oficina = P_oficina
				and TipoServicio = P_TipoServicio
				/*AND YEAR(HoraPeticion) = YEAR(sysdate())
				AND MONTH(HoraPeticion) = MONTH(sysdate())
				AND DAY(HoraPeticion) = DAY(sysdate())*/
				and Id > P_Id_TRUNC
				and IdPadre IS NULL
		);
	if iTurAct = 0 then	
		SELECT valor INTO vValor FROM parametros WHERE oficina = P_oficina and Id = 23;
		if vValor = 'S' then		
			set iTurAct = iNumeroMinimo - 1;
		end if;
	end if;

	set iTurAct = iTurAct + 1;
    if (iTurAct > iNumeroMaximo) then
	    set iTurAct = iNumeroMinimo;
    end if;
    if (iTurAct < iNumeroMinimo) then
		set iTurAct = iNumeroMinimo;
    end if;

	UPDATE tservicios SET TurnoActual = iTurAct WHERE oficina = P_oficina and Id = P_TipoServicio;

	set P_Turno = iTurAct;


	
	set P_Cont = 0;
	
	SELECT COUNT(0) INTO P_Cont FROM regtransac_hoy WHERE oficina = P_oficina and Turno = P_Turno AND HoraPeticion >= CURDATE();
	
	IF P_Cont > 0 THEN
		
		set P_Cont = 0;
		select fechaact - evaluar INTO P_Cont
		from (
			select fechaact, evaluar + 1 evaluar
			from (
				select sysdate() + 1 fechaact, MAX(HoraPeticion) evaluar 
				FROM regtransac_hoy
				WHERE oficina = P_oficina and Turno = P_Turno
					/*AND YEAR(HoraPeticion) = YEAR(sysdate())
					AND MONTH(HoraPeticion) = MONTH(sysdate())
					AND DAY(HoraPeticion) = DAY(sysdate())*/
					and Id > P_Id_TRUNC
			) a
		) b;
		
		
		IF P_Cont < 900 THEN
			SET P_Cont = 100;
		ELSE
			SET P_Cont = 0;
		END IF;
		
	END IF;
	
	

IF P_Cont <> 100 THEN
	
	select P_HoraPeticion + 1 into P_Id;
	select date_format(sysdate(), '%Y-%m-%d') into P_Dia;
	set P_dDia = str_to_date(concat(P_Dia, ' 00:00:00'), '%Y-%m-%d %T');
	
	set P_Cont = 1;
	WHILE P_Cont > 0 DO
		select count(0) into P_Cont from regtransac_hoy where oficina = P_oficina and Id = P_Id;
		IF P_Cont > 0 Then
			Set P_Id = P_Id + 1;
		END IF;
	END WHILE;
	
	IF P_DIRECCION_IP IS NOT NULL THEN
		SELECT IFNULL(MAX(Id), 0)
		INTO P_ID_ULT
		FROM regtransac_hoy
		WHERE oficina = P_oficina
			and TipoServicio = P_TipoServicio
			and UsuarioImpresion = P_USUARIO
			and DireccionIpImpresion = P_DIRECCION_IP;
			
		IF (P_Id - P_ID_ULT) < 2 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO SE PUDO GENERAR EL TURNO';
		END IF;
	END IF;

	INSERT INTO auditoria(tabla, valor, observacion, oficina)
	VALUES('CREAR TURNO', P_HoraPeticion, CONCAT(A_HoraPeticion, '\t', P_Id), P_oficina);
	

	INSERT INTO regtransac(oficina, Id, HoraPeticion, TipoServicio, Turno, HoraInicioAtencion, HoraLLamado, HoraFinAtencion, EstadoTurno, Sesion, 
		NombreCliente, TipoDocumento, Documento, IdSala, Prefijo, UsuarioImpresion, DireccionIpImpresion)
	VALUES(P_oficina, P_Id, sysdate(), P_TipoServicio, P_Turno, P_HoraInicioAtencion, P_HoraLLamado, P_HoraFinAtencion, P_EstadoTurno, P_Sesion, 
		P_NombreCliente, P_TipoDocumento, P_Documento, P_IdSala, P_Prefijo, P_USUARIO, P_DIRECCION_IP);
		
	IF P_Subservicio IS NOT NULL THEN
		INSERT INTO RegTranSubser(Oficina, IdR, IdS, Consecutivo, FechaIni, FechaFin)
		VALUES(P_oficina, P_Id, P_Subservicio, 0, sysdate(), sysdate());
	END IF;

	
	OPEN C_MU;
	cursor_loop: LOOP
		FETCH C_MU INTO P_IdFuncionario, P_Descripcion, P_FechaEspera;
		IF exit_loop THEN
			LEAVE cursor_loop;
		END IF;
	END LOOP cursor_loop;
	CLOSE C_MU;
		
	
	/*select MAX(Turno) INTO P_MaxTurno from regtransac where oficina = P_oficina and HoraPeticion >= P_dDia and TipoServicio = P_TipoServicio;*/
    select MAX(Turno) INTO P_MaxTurno from regtransac_hoy where oficina = P_oficina and Id >= P_Id_TRUNC and TipoServicio = P_TipoServicio;
    
	UPDATE tservicios SET TurnoActual = P_MaxTurno WHERE oficina = P_oficina and Id = P_TipoServicio;
	
	set P_Cont = 0;
	SELECT COUNT(0) INTO P_Cont FROM cola_servicio WHERE IdServicio = P_TipoServicio;
	IF P_Cont > 0 THEN
		SET exit_loop = FALSE;
		OPEN C_CS;
		cursor_loop: LOOP
			FETCH C_CS INTO P_IdCampo, P_Valor;
			IF exit_loop THEN
				LEAVE cursor_loop;
			ELSE
				DELETE FROM regtran_campos WHERE oficina = P_oficina and IdR = P_Id AND IdC = P_IdCampo;
				INSERT INTO regtran_campos(oficina, IdR, IdC, Valor)VALUES(P_oficina, P_Id, P_IdCampo, P_Valor);
			END IF;
		END LOOP cursor_loop;
		CLOSE C_CS;
		DELETE FROM cola_servicio WHERE oficina = P_oficina AND IdServicio = P_TipoServicio AND Id = P_IdColaServicio;	
	END IF;
	

	select COUNT(0) INTO P_Cont from regtransac where oficina = P_oficina and HoraPeticion >= P_dDia;
	IF P_Cont < 2 Then
		DELETE FROM cola_servicio;
	END IF;
	
END IF;

end;