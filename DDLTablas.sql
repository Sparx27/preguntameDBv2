-- PAIS
CREATE TABLE Paises(
	PaisId char(3),
	Nombre nvarchar(50) NOT NULL,

	CONSTRAINT PK_Paises PRIMARY KEY(PaisId)
)
-- FIN PAIS


-- USUARIO
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
CREATE INDEX IX_Usuarios_NombreUsuario on Usuarios(NombreUsuario)
CREATE INDEX IX_Usuarios_NombreCompleto on Usuarios(NombreCompleto)
-- FIN USUARIO


-- --INTERACCIONES-- --

-- PREGUNTA
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
-- FIN PREGUNTA


-- RESPUESTA
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
CREATE INDEX IX_FK_Respuesta_PreId ON Respuestas(PreguntaId)
-- FIN RESPUESTA


-- SEGUIMIENTO
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
-- FIN SEGUIMIENTO


-- MEGUSTA
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
-- FIN MEGUSTA


-- NOTIFICACIONES
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

	-- Asegurar una sola notificación por Seguimiento
	CONSTRAINT UQ_Notificaciones_Seguimientos UNIQUE (S_Usuario_Seguido, S_Usuario_Seguidor, Tipo),

	-- Asegurar una sola notificación por MeGusta
	CONSTRAINT UQ_Notificaciones_MeGustas UNIQUE (M_RespuestaId, M_UsuarioId, Tipo)
)
CREATE INDEX IX_Notificaciones_UsuarioId ON Notificaciones(UsuarioId)
CREATE INDEX IX_Notificaciones_S_Usuario_Seguido ON Notificaciones(S_Usuario_Seguido)
CREATE INDEX IX_Notificaciones_S_Usuario_Seguidor ON Notificaciones(S_Usuario_Seguidor)
CREATE INDEX IX_Notificaciones_M_RespuestaId ON Notificaciones(M_RespuestaId)
CREATE INDEX IX_Notificaciones_M_UsuarioId ON Notificaciones(M_UsuarioId)
-- FIN NOTIFICACIONES

-- --FIN INTERACCIONES-- --