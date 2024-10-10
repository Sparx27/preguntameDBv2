CREATE PROCEDURE SP_S_Seguidores (@NombreUsuario nvarchar(20))
AS
	SELECT u.NombreUsuario, u.Nombre, u.Apellido
	FROM Seguimientos s
	JOIN Usuarios u on u.UsuarioId = s.Usuario_Seguidor
	WHERE s.Usuario_Seguido = (
		select UsuarioId
		from Usuarios
		where NombreUsuario = @NombreUsuario
	)


CREATE PROCEDURE SP_S_Respuesta_Usuarios_MeGustas (@RespuestaId uniqueidentifier)
AS
	SELECT u.NombreUsuario, u.Nombre, u.Apellido
	FROM MeGustas m
	JOIN Usuarios u on u.UsuarioId = m.UsuarioId
	WHERE m.RespuestaId = @RespuestaId


CREATE PROCEDURE SP_S_Usuario_NSiguiendo (@NombreUsuario nvarchar(20), @NSeguimientos int = 0 OUTPUT)
AS
	IF NOT EXISTS (SELECT 'existe' FROM Usuarios WHERE NombreUsuario = @NombreUsuario)
		SET @NSeguimientos = -1
	ELSE
		SELECT @NSeguimientos = count(s.Usuario_Seguido)
		FROM Seguimientos s
		JOIN Usuarios u on u.UsuarioId = s.Usuario_Seguidor
		WHERE u.NombreUsuario = @NombreUsuario

--DECLARE @N int
--EXEC SP_S_Usuario_NSiguiendo 'sanben', @n output
--select @n

CREATE PROCEDURE SP_S_TopUsuariosActivos(@Dias int, @Cantidad int)
AS
	select TOP (ISNULL(@Cantidad, 3))
	u.UsuarioId, 
	u.NombreUsuario, 
	nmegustas.nm as MeGustas, 
	nseguimientos.ns as Seguimientos, 
	(nmegustas.nm + nseguimientos.ns) as Interacciones, 
	(
		CASE
			WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) < 3 THEN 'Bajo'
			WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) < 5 THEN 'Medio'
			WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) >= 5 THEN 'Alto'
		END
	) as Ranked
	from usuarios u
	left join (
		select u.UsuarioId as mu, count(m.UsuarioId) as nm
		from Usuarios u
		left join MegUSTAS m on u.UsuarioId = m.UsuarioId
		group by u.UsuarioId
	) as nmegustas on nmegustas.mu = u.usuarioid
	left join (
		select u.UsuarioId as su, count(s.Usuario_Seguidor) as ns
		from Usuarios u
		left join Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
		group by u.UsuarioId
	) as nseguimientos on nseguimientos.su = u.UsuarioId
	order by Interacciones desc, u.NombreUsuario


	update t
set ranked = (
	CASE
	WHEN (select count(u.id) from u join Interacciones i on i.usuarioid = u.id) < 10 THEN 'Bajo'
	WHEN (select count(u.id) from u join Interacciones i on i.usuarioid = u.id) between 10 and 29 THEN 'Medio'
	WHEN (select count(u.id) from u join Interacciones i on i.usuarioid = u.id) > 29 THEN 'Alto'
)
From Usuarios u


select u.UsuarioId, 
			 u.NombreUsuario, 
			 nmegustas.nm as MeGustas, 
			 nseguimientos.ns as Seguimientos, 
			 (nmegustas.nm + nseguimientos.ns) as Interacciones, 
			 (
					CASE
						WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) < 3 THEN 'Bajo'
						WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) < 5 THEN 'Medio'
						WHEN ISNULL(nmegustas.nm, 0) + ISNULL(nseguimientos.ns, 0) >= 5 THEN 'Alto'
					END
			 ) as Ranked
from usuarios u
left join (
	select u.UsuarioId as mu, count(m.UsuarioId) as nm
	from Usuarios u
	left join MegUSTAS m on u.UsuarioId = m.UsuarioId
	group by u.UsuarioId
) as nmegustas on nmegustas.mu = u.usuarioid
left join (
	select u.UsuarioId as su, count(s.Usuario_Seguidor) as ns
	from Usuarios u
	left join Seguimientos s on s.Usuario_Seguidor = u.UsuarioId
	group by u.UsuarioId
) as nseguimientos on nseguimientos.su = u.UsuarioId
order by Interacciones desc, u.NombreUsuario