-- Cuando un usuario se Confirme mediante su Email, automáticamente debería pasar a estar Activo
CREATE TRIGGER trg_Usuario_Confirmado_EntoncesActivo
ON Usuarios
AFTER Update
AS
BEGIN
	SET NOCOUNT ON

	-- Ejecutar este trigger solamente para cuando un usuario se confirma por email (Confirmado pasa de 0 a 1)
	IF EXISTS (
		Select 1
		from inserted i
		join deleted d on d.UsuarioId = i.UsuarioId
		where i.Confirmado = 1 and d.Confirmado = 0
	)
	-- Se Confirma mediante su Email y entonces pasa a estar Activo
		Update Usuarios
		set Activo = 1
		where UsuarioId IN ( select UsuarioId from inserted where Confirmado = 1 )
END


-- Cuando un usuario abra una notificacion relacionada al recibir un Me Gusta o un Seguimiento:
-- Se agrega la fecha y hora de esa acción.
-- Esto tiene como finalidad, que luego mediante un Job, se eliminen luego de pasadas 24 horas
CREATE TRIGGER trg_Notificacion_FechaVista
ON Notificaciones
AFTER Update
AS
BEGIN
	SET NOCOUNT ON

	Update n
	set FechaVista = GETDATE()
	from Notificaciones n
	join inserted i on i.NotificacionId = n.NotificacionId
	join deleted d on d.NotificacionId = n.NotificacionId
	where i.Estado = 1 and d.Estado = 0
	-- El where asegura que es un caso en que la notificacion pasa de no vista (0) a vista (1)
END

-- Cuando se borra una respuesta, no tiene sentido conservar la pregunta
CREATE TRIGGER trg_Borrar_Respuesta_JuntoA_Pregunta
ON Respuestas
AFTER Delete
AS
BEGIN
	SET NOCOUNT ON

	Delete from Preguntas
	where PreguntaId IN (
		select PreguntaId
		from deleted
	)
END