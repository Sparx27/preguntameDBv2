CREATE PROCEDURE SP_S_Seguidores (@NombreUsuario nvarchar(20))
AS
BEGIN
	SET NOCOUNT ON

	SELECT u.NombreUsuario, u.NombreCompleto, u.Foto
	FROM Usuarios u
	JOIN Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
	JOIN Usuarios uSeguido on uSeguido.UsuarioId = s.Usuario_Seguido
	WHERE uSeguido.NombreUsuario = @NombreUsuario
END


CREATE PROCEDURE SP_S_Respuesta_MeGustas_Usuarios (@RespuestaId uniqueidentifier)
AS
BEGIN
	SET NOCOUNT ON

	SELECT u.NombreUsuario, u.NombreCompleto, u.Foto
	FROM Usuarios u
	JOIN MeGustas m on m.UsuarioId = u.UsuarioId
	WHERE m.RespuestaId = @RespuestaId
END


CREATE PROCEDURE SP_S_TopUsuariosActivos(@Dias int = 7, @Cantidad int = 5)
AS
BEGIN
	SET NOCOUNT ON

	select top (@Cantidad)
		u.UsuarioId, 
		u.NombreUsuario, 
		dbo.F_ContarMeGustasDadosPorNombreUsuario(u.NombreUsuario, @Dias) as MeGustas, 
		dbo.F_ContarSeguimientosDadosPorNombreUsuario(u.NombreUsuario, @Dias) as Seguimientos,
		(dbo.F_ContarMeGustasDadosPorNombreUsuario(u.NombreUsuario, @Dias) + 
			dbo.F_ContarSeguimientosDadosPorNombreUsuario(u.NombreUsuario, @Dias)) as Interacciones
	from usuarios u
	order by Interacciones desc, u.NombreUsuario
END
