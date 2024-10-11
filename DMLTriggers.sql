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