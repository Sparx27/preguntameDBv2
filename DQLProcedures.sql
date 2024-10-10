CREATE PROCEDURE SP_S_Seguidores (@NombreUsuario nvarchar(20))
AS
	SELECT u.NombreUsuario, u.NombreCompleto, u.Foto
	FROM Usuarios u
	JOIN Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
	JOIN Usuarios uSeguido on uSeguido.UsuarioId = s.Usuario_Seguido
	WHERE uSeguido.NombreUsuario = @NombreUsuario


CREATE PROCEDURE SP_S_Respuesta_MeGustas_Usuarios (@RespuestaId uniqueidentifier)
AS
	SELECT u.NombreUsuario, u.NombreCompleto, u.Foto
	FROM Usuarios u
	JOIN MeGustas m on m.UsuarioId = u.UsuarioId
	WHERE m.RespuestaId = @RespuestaId


CREATE PROCEDURE SP_S_TopUsuariosActivos(@Dias int = 1, @Cantidad int = 5)
AS
	SELECT TOP (@Cantidad)
	u.UsuarioId, 
	u.NombreUsuario, 
	ISNULL(nmegustas.nm, 0) as MeGustas, 
  ISNULL(nseguimientos.ns, 0) as Seguimientos,
	ISNULL(nmegustas.nm + nseguimientos.ns, 0) as Interacciones
	FROM usuarios u
	left join (
		select u.UsuarioId as mu, count(m.UsuarioId) as nm
		from Usuarios u
		join MeGustas m on u.UsuarioId = m.UsuarioId
		where m.Fecha >= DATEADD(DAY, -1 * @Dias, GETDATE()) --Por defecto, los dados en el mismo día
		group by u.UsuarioId
	) as nmegustas on nmegustas.mu = u.usuarioid
	left join (
		select u.UsuarioId as su, count(s.Usuario_Seguidor) as ns
		from Usuarios u
		join Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
		where s.Fecha >= DATEADD(DAY, -1 * @Dias, GETDATE()) --Por defecto, los dados en el mismo día
		group by u.UsuarioId
	) as nseguimientos on nseguimientos.su = u.UsuarioId
	order by Interacciones desc, u.NombreUsuario
