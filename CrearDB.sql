USE master
GO

-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'PreguntameDBv2')
BEGIN
    ALTER DATABASE PreguntameDBv2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PreguntameDBv2;
END

CREATE DATABASE PreguntameDBv2
GO

USE "PreguntameDBv2"
GO

-- CREAR TYPES --
create type descripcion from nvarchar(300) not null
GO

-- CREAR TABLAS --
CREATE TABLE Paises(
	PaisId char(3),
	Nombre nvarchar(50) NOT NULL,

	CONSTRAINT PK_Paises PRIMARY KEY(PaisId)
)
GO

CREATE TABLE Usuarios(
	UsuarioId uniqueidentifier DEFAULT NEWID(),
	Confirmado bit DEFAULT 0,
	Activo bit DEFAULT 0,
	Email nvarchar(100) NOT NULL UNIQUE,
	Contrasena nvarchar(70) NOT NULL,
	NombreUsuario nvarchar(20) NOT NULL UNIQUE,
	Nombre nvarchar(20) NOT NULL,
	Apellido nvarchar(30),
	NombreCompleto AS (Nombre + ' ' + Apellido) PERSISTED,
	Foto nvarchar(250),
	Bio nvarchar(250),
	CajaPreguntas nvarchar(50),
	NLikes int DEFAULT 0 NOT NULL,
	NSeguidores int DEFAULT 0 NOT NULL,
	PaisId char(3) NOT NULL,
	
	CONSTRAINT PK_Usuarios PRIMARY KEY(UsuarioId),
	CONSTRAINT CK_ConfirmadoActivo CHECK((Confirmado = 1 OR Activo = 0)),
	CONSTRAINT CK_Contrasena CHECK(
		Contrasena like '%[a-z]%' AND
		Contrasena like '%[A-Z]%' AND
		Contrasena like '%[0-9]%' AND
		LEN(Contrasena) >= 6
	),
	CONSTRAINT CK_NombreUsuario CHECK(Len(NombreUsuario) > 3),
	CONSTRAINT FK_Usuario_Pais FOREIGN KEY(PaisId) REFERENCES Paises(PaisId)
)
GO
CREATE INDEX IX_Usuarios_NombreUsuario on Usuarios(NombreUsuario)
GO
CREATE INDEX IX_Usuarios_NombreCompleto on Usuarios(NombreCompleto)
GO

CREATE TABLE Preguntas(
	PreguntaId uniqueidentifier DEFAULT NEWID(),
	Usuario_Recibe uniqueidentifier NOT NULL,
	Usuario_Envia uniqueidentifier,
	Dsc descripcion,
	Fecha datetime DEFAULT GETDATE() NOT NULL,
	Estado bit DEFAULT 0 NOT NULL,

	CONSTRAINT PK_Preguntas PRIMARY KEY(PreguntaId),
	CONSTRAINT FK_Pregunta_UsuRecibe FOREIGN KEY(Usuario_Recibe) REFERENCES Usuarios(UsuarioId),
	CONSTRAINT FK_Pregunta_UsuEnvia FOREIGN KEY(Usuario_Envia) REFERENCES Usuarios(UsuarioId)
)
CREATE INDEX IX_FK_Pregunta_Usuario_Recibe ON Preguntas(Usuario_Recibe)
CREATE INDEX IX_FK_Pregunta_Usuario_Envia ON Preguntas(Usuario_Envia)
GO

CREATE TABLE Respuestas(
	RespuestaId uniqueidentifier DEFAULT NEWID(),
	PreguntaId uniqueidentifier NOT NULL,
	Dsc descripcion,
	Fecha datetime DEFAULT GETDATE() NOT NULL,
	NLikes int DEFAULT 0 NOT NULL,

	CONSTRAINT PK_Respuestas PRIMARY KEY(RespuestaId),
	CONSTRAINT UQ_PreguntaId UNIQUE(PreguntaId),
	CONSTRAINT FK_Respuestas_Preguntas FOREIGN KEY(PreguntaId) REFERENCES Preguntas(PreguntaId)
)
GO
CREATE INDEX IX_FK_Respuesta_PreId ON Respuestas(PreguntaId)
GO

CREATE TABLE Seguimientos(
	Usuario_Seguido uniqueidentifier,
	Usuario_Seguidor uniqueidentifier,
	Fecha datetime DEFAULT GETDATE() NOT NULL,

	CONSTRAINT PK_Seguimientos PRIMARY KEY(Usuario_Seguido, Usuario_Seguidor),
	CONSTRAINT FK_Seguimiento_Usuario_Seguido FOREIGN KEY(Usuario_Seguido)
		REFERENCES Usuarios(UsuarioId),
	CONSTRAINT FK_Seguimiento_Usuario_Seguidor FOREIGN KEY(Usuario_Seguidor)
		REFERENCES Usuarios(UsuarioId)
)
GO

CREATE TABLE MeGustas(
	RespuestaId uniqueidentifier,
	UsuarioId uniqueidentifier,
	Fecha datetime DEFAULT GETDATE() NOT NULL,

	CONSTRAINT PK_MeGustas PRIMARY KEY(RespuestaId, UsuarioId),
	CONSTRAINT FK_MeGustas_Respuestas FOREIGN KEY(RespuestaId) 
		REFERENCES Respuestas(RespuestaId),
	CONSTRAINT FK_MeGustas_Usuarios FOREIGN KEY(UsuarioId)
		REFERENCES Usuarios(UsuarioId)
)
GO

CREATE TABLE Notificaciones(
	NotificacionId uniqueidentifier DEFAULT NEWID(),
	UsuarioId uniqueidentifier,
	Estado bit DEFAULT 0 NOT NULL,
	Fecha datetime DEFAULT GETDATE() NOT NULL,
	Tipo char(1) NOT NULL,
	S_Usuario_Seguido uniqueidentifier,
	S_Usuario_Seguidor uniqueidentifier,
	M_RespuestaId uniqueidentifier,
	M_UsuarioId uniqueidentifier,

	CONSTRAINT PK_Notificaciones PRIMARY KEY(NotificacionId, UsuarioId),
	CONSTRAINT FK_Notificaciones_Usuarios FOREIGN KEY(UsuarioId)
		REFERENCES Usuarios(UsuarioId),
	CONSTRAINT CK_Tipo CHECK(Tipo IN ('S', 'M')),
	CONSTRAINT CK_Tipo_Seguimiento CHECK (Tipo != 'S' OR S_Usuario_Seguidor IS NOT NULL),
	CONSTRAINT CK_Tipo_MeGusta CHECK (Tipo != 'M' OR M_RespuestaId IS NOT NULL),
	CONSTRAINT FK_Notificaciones_Seguimientos FOREIGN KEY(S_Usuario_Seguido, S_Usuario_Seguidor)
		REFERENCES Seguimientos(Usuario_Seguido, Usuario_Seguidor),
	CONSTRAINT FK_Notificaciones_MeGustas FOREIGN KEY(M_RespuestaId, M_UsuarioId)
		REFERENCES MeGustas(RespuestaId, UsuarioId),
	CONSTRAINT UQ_Notificaciones_Seguimientos UNIQUE (S_Usuario_Seguido, S_Usuario_Seguidor, Tipo),
	CONSTRAINT UQ_Notificaciones_MeGustas UNIQUE (M_RespuestaId, M_UsuarioId, Tipo)
)
GO
CREATE INDEX IX_Notificaciones_UsuarioId ON Notificaciones(UsuarioId)
GO
CREATE INDEX IX_Notificaciones_S_Usuario_Seguido ON Notificaciones(S_Usuario_Seguido)
GO
CREATE INDEX IX_Notificaciones_S_Usuario_Seguidor ON Notificaciones(S_Usuario_Seguidor)
GO
CREATE INDEX IX_Notificaciones_M_RespuestaId ON Notificaciones(M_RespuestaId)
GO
CREATE INDEX IX_Notificaciones_M_UsuarioId ON Notificaciones(M_UsuarioId)
GO
-- FIN CREAR TABLAS --

-- FUNCTIONS --
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
GO

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
GO
-- FIN FUNCTIONS --


-- TRIGGERS -- 
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
GO
-- FIN TRIGGERS --


-- STORED PROCEDURES --
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
GO

CREATE PROCEDURE SP_S_Respuesta_MeGustas_Usuarios (@RespuestaId uniqueidentifier)
AS
BEGIN
	SET NOCOUNT ON

	SELECT u.NombreUsuario, u.NombreCompleto, u.Foto
	FROM Usuarios u
	JOIN MeGustas m on m.UsuarioId = u.UsuarioId
	WHERE m.RespuestaId = @RespuestaId
END
GO

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
GO

CREATE PROCEDURE SP_T_Toggle_MeGusta_Respuesta (@RespuestaId uniqueidentifier, @NombreUsuario nvarchar(20))
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF EXISTS (select 1 from Respuestas where RespuestaId = @RespuestaId) AND
			 EXISTS (select 1 from Usuarios where NombreUsuario = @NombreUsuario)
		BEGIN

			--Obtengo y guardo el UsuarioId que pertenece a ese NombreUsuario, facilita el manejo de las tablas
			DECLARE @UsuarioId uniqueidentifier
			SET @UsuarioId = (select UsuarioId from Usuarios where NombreUsuario = @NombreUsuario)

			-- Caso Usuario da un Like a Respuesta
			IF NOT EXISTS (select 1 from MeGustas where RespuestaId = @RespuestaId and UsuarioId = @UsuarioId)
			BEGIN
				BEGIN TRANSACTION

					Insert into MeGustas(RespuestaId, UsuarioId)
					select @RespuestaId, UsuarioId from Usuarios where NombreUsuario = @NombreUsuario

					Update Respuestas
					set NLikes = Nlikes + 1
					where	Respuestas.RespuestaId = @RespuestaId

					Update Usuarios
					set NLikes = NLikes + 1
					where UsuarioId = (
						select p.Usuario_Recibe
						from Preguntas p
						join Respuestas r on r.PreguntaId = p.PreguntaId
						where r.RespuestaId = @RespuestaId
					)

				COMMIT TRANSACTION
				Print 'Se agregó MeGusta correctamente'
			END

			-- Si no es el Primer escenario, entonces significa que el MeGusta existe y se debe eliminar
			ELSE
				BEGIN
					BEGIN TRANSACTION
				
					Delete from MeGustas
					where RespuestaId = @RespuestaId and UsuarioId = @UsuarioId

					Update Respuestas
					set NLikes = NLikes - 1
					where RespuestaId = @RespuestaId

					Update Usuarios
					set NLikes = NLikes - 1
					where UsuarioId = (
						select p.Usuario_Recibe
						from Preguntas p
						join Respuestas r on r.PreguntaId = p.PreguntaId
						where r.RespuestaId = @RespuestaId
					)

					COMMIT TRANSACTION
					Print 'Se quitó MeGusta correctamente'
				END
		END -- Del primer IF
		ELSE
			PRINT 'No existe una Respuesta por esa RespuestaId o no existe un Usuario por ese UsuarioId'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0 
		BEGIN
			ROLLBACK TRANSACTION
			Print 'Error en la ejecución'
		END
	END CATCH
END
GO

CREATE PROCEDURE SP_T_Toggle_SeguimientoEntre_Usuarios (@UsuarioSeguido nvarchar(20), @UsuarioSeguidor nvarchar(20))
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF EXISTS(select 1 from Usuarios where NombreUsuario = @UsuarioSeguido) AND
			 EXISTS(select 1 from Usuarios where NombreUsuario = @UsuarioSeguidor) AND
			 @UsuarioSeguido != @UsuarioSeguidor
		BEGIN
			
			-- Guardo los UsuarioIds de ambos para facilitar el manejo de tablas
			DECLARE @UsuarioSeguidoId uniqueidentifier
			SET @UsuarioSeguidoId = (select UsuarioId from Usuarios where NombreUsuario = @UsuarioSeguido)
			DECLARE @UsuarioSeguidorId uniqueidentifier
			SET @UsuarioSeguidorId = (select UsuarioId from Usuarios where NombreUsuario = @UsuarioSeguidor)

			-- Caso en que un Usuario sigue a otro Usuario
			IF NOT EXISTS(select 1 from Seguimientos where Usuario_Seguido = @UsuarioSeguidoId and Usuario_Seguidor = @UsuarioSeguidorId)
			BEGIN
				BEGIN TRANSACTION

					Insert into Seguimientos(Usuario_Seguido, Usuario_Seguidor)
					values(@UsuarioSeguidoId, @UsuarioSeguidorId)

					Update Usuarios
					set NSeguidores = NSeguidores + 1
					where UsuarioId = @UsuarioSeguidoId

				COMMIT TRANSACTION
				PRINT 'Seguimiento realizado correctamente'
			END

			-- El otro escenario es que si exista el Seguimiento, y un Usuario deja de seguir a otro Usuario
			ELSE
			BEGIN
				BEGIN TRANSACTION

					Delete from Seguimientos
					where Usuario_Seguido = @UsuarioSeguidoId and Usuario_Seguidor = @UsuarioSeguidorId

					Update Usuarios
					set NSeguidores = NSeguidores - 1
					where UsuarioId = @UsuarioSeguidoId

				COMMIT TRANSACTION
				PRINT 'Seguimiento eliminado correctamente'
			END

		END
		ELSE
			PRINT 'Uno o ambos Nombres de Usuario, no pertenecen a Usuarios'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Error en la ejecución'
		END
	END CATCH
END
GO
-- FIN STORED PROCEDURES -- 

-- INSERTS --
INSERT INTO Paises VALUES
('URU', 'Uruguay'),
('ARG', 'Argentina'),
('MEX', 'México'),
('PER', 'Perú'),
('COL', 'Colombia'),
('ESP', 'España')
GO

INSERT INTO Usuarios
	(UsuarioId, Confirmado, Activo, Email, NombreUsuario, Contrasena, Nombre, Apellido, PaisId)
VALUES
	('1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 1, 1, 'fer25de25prueba252@gmail.com', 'fer25', 'Prueba123', 'Fernando', 'Pérez', 'URU'),
	('C1D151D6-32EB-462E-9163-B62420940AA3', 1, 1, 'sof25de25prueba252@gmail.com', 'sof25', 'Prueba123', 'Sofía', 'Martinez', 'URU'),
	('DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 1, 1, 'san25de25prueba252@gmail.com', 'sanben', 'Prueba123', 'Santiago', 'Benites', 'URU'),
	('7D8E65EA-AE06-4994-A962-EC04468A23DB', 1, 1, 'vic25de25prueba252@gmail.com', 'vicu', 'Prueba123', 'Victoria', 'Correa', 'ARG'),
	('984296BE-CFB8-4F07-868C-88E68B09C76F', 1, 1, 'jho25de25prueba252@gmail.com', 'jdoe', 'Prueba123', 'Jhon', 'Doe', 'ESP')
GO

INSERT INTO Preguntas(PreguntaId, Usuario_Envia, Usuario_Recibe, Dsc) VALUES
(
	'F634F9CF-C3CA-4324-950A-C21A42D0E0AA', 
	'C1D151D6-32EB-462E-9163-B62420940AA3', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'¿Qué libro o película te ha impactado más en la vida?'
),
(
	'F4F09A97-87BB-485C-AF6F-D32B39E8A68F', 
	null, '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'¿Cuál es tu lugar favorito para viajar y por qué?'
),
(
	'835C7FF3-7BD3-4DD3-84FA-77023332BDFF',
	'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'¿Qué habilidad te gustaría aprender si tuvieras tiempo y recursos ilimitados?'
),
(
	'C6D87D6D-1872-4626-AC50-5DEF28087963', 
	null, 'C1D151D6-32EB-462E-9163-B62420940AA3', 
	'Si pudieras cenar con cualquier persona, viva o no, ¿quién sería y qué le preguntarías?'
),
(
	'22105A04-A4BB-4A53-9676-BCA3763C5BEB', 
	null, '984296BE-CFB8-4F07-868C-88E68B09C76F', 
	'¿Cuál es tu recuerdo más preciado de la infancia?'
),
(
	'4ECD7A23-7688-4977-A2AE-D9687130BFAF',
	'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 'C1D151D6-32EB-462E-9163-B62420940AA3', 
	'¿Qué consejo le darías a tu yo más joven si pudieras?'
),
(
	'1B84271B-72D8-4CD3-B57A-3752A21490C0', 
	'7D8E65EA-AE06-4994-A962-EC04468A23DB', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 
	'¿Cuál es tu plato favorito y qué lo hace especial para ti?'
)
GO

INSERT INTO Respuestas(RespuestaId, PreguntaId, Dsc) VALUES
(
	'B97CFFF5-2FF4-4D71-9B28-38E62EDB2B8D',
	'F4F09A97-87BB-485C-AF6F-D32B39E8A68F', 'Me encanta Japón por su mezcla de tradición y modernidad.'
),
(
	'D44DF95C-4CB6-4B5C-978C-CFDECD79CB73',
	'F634F9CF-C3CA-4324-950A-C21A42D0E0AA', '"Ética a Nicómaco" de Aristóteles, lo recomiendo.'
),
(
	'EF73DC4E-7B29-4B73-845D-7B4066CD2CB9', 
	'C6D87D6D-1872-4626-AC50-5DEF28087963', 'Cenaría con Albert Einstein y le preguntaría sobre su proceso creativo.'
),
(
	'A50E8B78-43A2-4230-A53E-D0D534306BFA', 
	'22105A04-A4BB-4A53-9676-BCA3763C5BEB', 'Jugar en el campo con mis amigos durante el verano.'
),
(
	'32CCA49F-F83B-40A2-8BD0-B5F22DDD56F7', 
	'4ECD7A23-7688-4977-A2AE-D9687130BFAF', 'Todo lo bueno que quieras lograr en la vida, va a requerir en menor o mayor medida de tu autodisciplina.'
)
GO

UPDATE Preguntas
SET Estado = 1
WHERE Preguntas.PreguntaId IN (
	select p.PreguntaId
	from Preguntas p
	join Respuestas r on r.PreguntaId = p.PreguntaId
)
GO

INSERT INTO Seguimientos(Usuario_Seguido, Usuario_Seguidor) VALUES
('C1D151D6-32EB-462E-9163-B62420940AA3', '7D8E65EA-AE06-4994-A962-EC04468A23DB'),
('C1D151D6-32EB-462E-9163-B62420940AA3', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A'),
('1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', '7D8E65EA-AE06-4994-A962-EC04468A23DB'),
('1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 'C1D151D6-32EB-462E-9163-B62420940AA3'),
('C1D151D6-32EB-462E-9163-B62420940AA3', '984296BE-CFB8-4F07-868C-88E68B09C76F'),
('984296BE-CFB8-4F07-868C-88E68B09C76F', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F'),
('984296BE-CFB8-4F07-868C-88E68B09C76F', '7D8E65EA-AE06-4994-A962-EC04468A23DB'),
('1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F'),
('7D8E65EA-AE06-4994-A962-EC04468A23DB', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F')
GO

UPDATE Usuarios
SET NSeguidores = (
	select count(s.Usuario_Seguido)
	from Seguimientos s
	where s.Usuario_Seguido = Usuarios.UsuarioId
)
GO

INSERT INTO MeGustas(RespuestaId, UsuarioId) VALUES
('B97CFFF5-2FF4-4D71-9B28-38E62EDB2B8D', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A'),
('B97CFFF5-2FF4-4D71-9B28-38E62EDB2B8D', '984296BE-CFB8-4F07-868C-88E68B09C76F'),
('EF73DC4E-7B29-4B73-845D-7B4066CD2CB9', '984296BE-CFB8-4F07-868C-88E68B09C76F'),
('32CCA49F-F83B-40A2-8BD0-B5F22DDD56F7', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A'),
('32CCA49F-F83B-40A2-8BD0-B5F22DDD56F7', '7D8E65EA-AE06-4994-A962-EC04468A23DB'),
('32CCA49F-F83B-40A2-8BD0-B5F22DDD56F7', 'C1D151D6-32EB-462E-9163-B62420940AA3'),
('D44DF95C-4CB6-4B5C-978C-CFDECD79CB73', 'C1D151D6-32EB-462E-9163-B62420940AA3'),
('D44DF95C-4CB6-4B5C-978C-CFDECD79CB73', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F'),
('A50E8B78-43A2-4230-A53E-D0D534306BFA', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F'),
('A50E8B78-43A2-4230-A53E-D0D534306BFA', '7D8E65EA-AE06-4994-A962-EC04468A23DB')
GO

UPDATE Usuarios
SET NLikes = (
	select count(m.UsuarioId)
	from MeGustas m
	where m.UsuarioId = Usuarios.UsuarioId
)
GO

UPDATE Respuestas
SET NLikes = (
	select count(m.RespuestaId)
	from MeGustas m
	where m.RespuestaId = Respuestas.RespuestaId
)
-- FIN INSERTS --
