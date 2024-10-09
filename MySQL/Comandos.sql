-- Validar la versión de MySQL: 

SHOW VARIABLES LIKE '%version%';

-- Validar el tamaño de las bases de datos:

SELECT 
	table_schema AS 'turnosdb', 
	ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Size (MB)'  
FROM information_schema.TABLES  
WHERE table_schema = 'turnosdb' 
GROUP BY table_schema

-- Validar la granularidad de la información

SELECT table_name , 
	   ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Size (MB)'  
FROM information_schema.TABLES  
WHERE table_schema = 'turnosdb' 
GROUP BY table_name  
ORDER BY 2 DESC; 

SELECT COALESCE(MAX(Id) + 1) FROM regtransac_hoy

-- Validar los indices

SHOW INDEXES FROM regtransac

-- Validar ExplainPLan Consulta

explain
select *
FROM regtransac R
	INNER JOIN tsesion S ON R.Sesion = S.SesionL
	INNER JOIN tfuncionarios F ON S.IdFuncionario = F.IdFuncionarios
	INNER JOIN tpuntos P ON P.NumeroPunto = S.Caja
WHERE R.HoraPeticion = '2024-08-12'

-- Valdiar las sesiones activas

show full PROCESSLIST

select * from INFORMATION_SCHEMA.EVENTS
where EVENT_NAME = 'e_store_ts' 
and EVENT_SCHEMA = 'myschema'

explain
select * 
from turnosdb.regtransac 
WHERE Id > 20240925000000 AND TIMESTAMPDIFF (SECOND, HoraLLamado, HoraFinAtencion) > 7200 AND EstadoTurno <> 0

UPDATE turnosdb.regtransac SET EstadoTurno = 5 WHERE Id > 20240925000000 AND TIMESTAMPDIFF (SECOND, HoraLLamado, HoraFinAtencion) > 7200 AND EstadoTurno <> 0;
	
select DATE(NOW()) + 10000000

select DATE(SYSDATE()) * 1000000;

select count(*) from regtransac_hoy rh 

-- Cantidad de registros en tablas

show TABLES

SELECT COUNT(0), 'aprobacion' TABLA FROM aprobacion 
UNION SELECT COUNT(0), 'area' TABLA FROM area
UNION SELECT COUNT(0), 'atencion_dia ' TABLA FROM atencion_dia            
UNION SELECT COUNT(0), 'atencion_tfuncionarios ' TABLA FROM atencion_tfuncionarios  
UNION SELECT COUNT(0), 'atencion_tservicios ' TABLA FROM atencion_tservicios     
UNION SELECT COUNT(0), 'auditoria ' TABLA FROM auditoria               
UNION SELECT COUNT(0), 'calificacion ' TABLA FROM calificacion            
UNION SELECT COUNT(0), 'calificacion_pregunta ' TABLA FROM calificacion_pregunta   
UNION SELECT COUNT(0), 'campos_adicionales ' TABLA FROM campos_adicionales      
UNION SELECT COUNT(0), 'campos_valores ' TABLA FROM campos_valores          
UNION SELECT COUNT(0), 'cola_servicio ' TABLA FROM cola_servicio           
UNION SELECT COUNT(0), 'datos_usu_remision ' TABLA FROM datos_usu_remision      
UNION SELECT COUNT(0), 'datos_usuario ' TABLA FROM datos_usuario           
UNION SELECT COUNT(0), 'datos_usuario_denuncia ' TABLA FROM datos_usuario_denuncia  
UNION SELECT COUNT(0), 'motivo_deslogueo ' TABLA FROM motivo_deslogueo        
UNION SELECT COUNT(0), 'oficina ' TABLA FROM oficina                 
UNION SELECT COUNT(0), 'oficinas ' TABLA FROM oficinas                
UNION SELECT COUNT(0), 'parametro_plasma ' TABLA FROM parametro_plasma        
UNION SELECT COUNT(0), 'parametros ' TABLA FROM parametros              
UNION SELECT COUNT(0), 'permisos ' TABLA FROM permisos                
UNION SELECT COUNT(0), 'regtran_campos ' TABLA FROM regtran_campos          
UNION SELECT COUNT(0), 'regtransac ' TABLA FROM regtransac              
UNION SELECT COUNT(0), 'regtransac_hoy ' TABLA FROM regtransac_hoy          
UNION SELECT COUNT(0), 'regtransubser ' TABLA FROM regtransubser           
UNION SELECT COUNT(0), 'remisiones ' TABLA FROM remisiones              
UNION SELECT COUNT(0), 'salas ' TABLA FROM salas                   
UNION SELECT COUNT(0), 'subservice ' TABLA FROM subservice              
UNION SELECT COUNT(0), 'sucursales ' TABLA FROM sucursales              
UNION SELECT COUNT(0), 'sucursales_oficinas ' TABLA FROM sucursales_oficinas     
UNION SELECT COUNT(0), 'tblgraf ' TABLA FROM tblgraf                 
UNION SELECT COUNT(0), 'tbltemp ' TABLA FROM tbltemp                 
UNION SELECT COUNT(0), 'tcategoriaservicios ' TABLA FROM tcategoriaservicios     
UNION SELECT COUNT(0), 'tfuncionarios ' TABLA FROM tfuncionarios           
UNION SELECT COUNT(0), 'tfuncionarios_mensajes ' TABLA FROM tfuncionarios_mensajes  
UNION SELECT COUNT(0), 'tfuncionarios_oficinas ' TABLA FROM tfuncionarios_oficinas  
UNION SELECT COUNT(0), 'tfuncionarios_servicios ' TABLA FROM tfuncionarios_servicios 
UNION SELECT COUNT(0), 'tpuntos ' TABLA FROM tpuntos                 
UNION SELECT COUNT(0), 'tpuntos_funcionario ' TABLA FROM tpuntos_funcionario     
UNION SELECT COUNT(0), 'transacciones ' TABLA FROM transacciones           
UNION SELECT COUNT(0), 'traslado ' TABLA FROM traslado                
UNION SELECT COUNT(0), 'tservicios ' TABLA FROM tservicios              
UNION SELECT COUNT(0), 'tservicios_horario ' TABLA FROM tservicios_horario      
UNION SELECT COUNT(0), 'tsesion ' TABLA FROM tsesion                 
UNION SELECT COUNT(0), 'tsesion_hoy ' TABLA FROM tsesion_hoy             
UNION SELECT COUNT(0), 'tsubserviciomanual ' TABLA FROM tsubserviciomanual      
UNION SELECT COUNT(0), 'tsubservicios ' TABLA FROM tsubservicios           
UNION SELECT COUNT(0), 'tsubservicios_tservicios' TABLA FROM tsubservicios_tservicios
UNION SELECT COUNT(0), 'ttableros ' TABLA FROM ttableros               
UNION SELECT COUNT(0), 'wtr_agenda ' TABLA FROM wtr_agenda              
UNION SELECT COUNT(0), 'wtr_aplicacion ' TABLA FROM wtr_aplicacion          
UNION SELECT COUNT(0), 'wtr_bitacora ' TABLA FROM wtr_bitacora            
UNION SELECT COUNT(0), 'wtr_festivo ' TABLA FROM wtr_festivo             
UNION SELECT COUNT(0), 'wtr_perfil ' TABLA FROM wtr_perfil              
UNION SELECT COUNT(0), 'wtr_permiso ' TABLA FROM wtr_permiso
order by 1 DESC

-- Relevancia de Triggers

SELECT * FROM information_schema.TRIGGERS
where TRIGGER_SCHEMA = 'turnosdb'

--------------

SELECT  
    pl.id 
    ,pl.user 
    ,pl.state 
    ,it.trx_id  
    ,it.trx_mysql_thread_id  
    ,it.trx_query AS query 
    ,it.trx_id AS blocking_trx_id 
    ,it.trx_mysql_thread_id AS blocking_thread 
    ,it.trx_query AS blocking_query 
FROM information_schema.processlist AS pl  
INNER JOIN information_schema.innodb_trx AS it 
    ON pl.id = it.trx_mysql_thread_id 
INNER JOIN information_schema.innodb_lock_waits AS ilw 
    ON it.trx_id = ilw.requesting_trx_id  
    AND it.trx_id = ilw.blocking_trx_id 

select * FROM information_schema.innodb_lock_waits
LIMIT 0, 200


SHOW VARIABLES LIKE 'innodb_status_output_locks';

SET GLOBAL innodb_status_output_locks = on;


SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'information_schema' 
AND table_name LIKE 'INNODB%';



-- Validar procesos bloqueados: 

SHOW ENGINE INNODB STATUS

-- validar trafico de red

SHOW STATUS LIKE 'Bytes_received'

SHOW STATUS LIKE 'Bytes_sent'

SHOW VARIABLES LIKE 'pid_file';

-- validación de qry:

EXPLAIN SELECT * FROM regtransac WHERE oficina = '101' AND EstadoTurno = 3 AND TipoServicio = 2;

-- Optimizaciones:

explain

SELECT IFNULL(MAX(Turno), 0)
FROM regtransac
WHERE oficina = '24 horas'
	and TipoServicio = 1
	and HoraPeticion = (
		SELECT MAX(HoraPeticion)
		FROM regtransac
		WHERE oficina = '24 horas'
			and TipoServicio = 1
			AND YEAR(HoraPeticion) = YEAR(sysdate())
			AND MONTH(HoraPeticion) = MONTH(sysdate())
			AND DAY(HoraPeticion) = DAY(sysdate())
			and IdPadre IS NULL
	);


show indexes from regtransac;
select sysdate(); 

explain

SELECT IFNULL(MAX(Turno), 0)
	FROM regtransac_hoy
	WHERE oficina = '24 horas'
		and TipoServicio = 1
		and HoraPeticion = (
			SELECT MAX(HoraPeticion)
			FROM regtransac_hoy
			WHERE oficina = '24 horas'
				and TipoServicio = 1
				/*AND YEAR(HoraPeticion) = YEAR(sysdate())
				AND MONTH(HoraPeticion) = MONTH(sysdate())
				AND DAY(HoraPeticion) = DAY(sysdate())*/
				and Id > 20240915000000
				and IdPadre IS NULL
		);