CREATE FUNCTION F_ContarMeGustasDadosPorNombreUsuario (@NombreUsuario nvarchar(20), @Dias int = 7)
RETURNS int
AS
BEGIN
	RETURN (
		select count(m.UsuarioId)
		from Usuarios u
		join MeGustas m on u.UsuarioId = m.UsuarioId
		where m.Fecha >= DATEADD(DAY, -1 * @Dias, GETDATE()) --Por defecto, los dados en la última semana
			and u.NombreUsuario = @NombreUsuario
	)
END

CREATE FUNCTION F_ContarSeguimientosDadosPorNombreUsuario (@NombreUsuario nvarchar(20), @Dias int = 7)
RETURNS int
AS
BEGIN
	RETURN (
		select count(s.Usuario_Seguidor)
		from Usuarios u
		join Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
		where s.Fecha >= DATEADD(DAY, -1 * @Dias, GETDATE()) --Por defecto, los dados en la última semana
			and u.NombreUsuario = @NombreUsuario
	)
END
