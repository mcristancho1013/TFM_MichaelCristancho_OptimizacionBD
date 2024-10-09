CREATE DEFINER=`admin`@`%` PROCEDURE `turnosdb`.`insertarRegTransac`(
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
  OUT P_Id decimal(16)
)
    SQL SECURITY INVOKER
BEGIN
SELECT 0,20230506220000 INTO P_Turno, P_Id;
END;