-- La idea ser�a eliminar Notificaciones que ya hayan sido vistas hace m�s de 24 horas
-- Limpiando as� registros inecesarios en la base de datos

-- Este stored procedure trabaja junto al trigger "trg_Notificacion_FechaVista" que agrega autom�ticamente la fehca-hora de cuando
-- un Usuario ve una Notificaci�n

-- La idea en esta l�gica ser�a agregar este procedure en un Job
CREATE PROCEDURE SP_D_Notificaciones_Vistas
AS
BEGIN
	SET NOCOUNT ON

	Delete from Notificaciones
	where Estado = 1 and
				FechaVista < dateadd(hour, -24, getdate())

END


-- Este ser�a el c�diga para agregar en un Job y hacer Backups

-- Para crear los nombres din�micamente
DECLARE @fecha char(8)
DECLARE @path varchar(100)
DECLARE @name varchar(30)

SET @fecha = convert(char(8), GETDATE(), 112)
SET @path = 'C:\BackupPreguntameDBv2\PreguntameDBv2'+@fecha+'.bak'
SET @name = 'PreguntameDBv2_1'+@fecha

BACKUP DATABASE PreguntameDBv2
TO DISK = @path
WITH NO_COMPRESSION, NAME = @name