create database PreguntameDBv2

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
	Email nvarchar(150) NOT NULL,
	Contrasena nvarchar(70) NOT NULL,
	Nombre nvarchar(20) NOT NULL,
	Apellido nvarchar(30),
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
	CONSTRAINT FK_Usuario_Pais FOREIGN KEY(PaisId) REFERENCES Paises(PaisId)
)
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
	Existe bit default 1,

	CONSTRAINT PK_Seguimientos PRIMARY KEY(Usuario_Seguido, Usuario_Seguidor),
	CONSTRAINT FK_Seguimiento_Usuario_Seguido FOREIGN KEY(Usuario_Seguido)
		REFERENCES Usuarios(UsuarioId),
	CONSTRAINT FK_Seguimiento_Usuario_Seguidor FOREIGN KEY(Usuario_Seguidor)
		REFERENCES Usuarios(UsuarioId)
)
-- FIN SEGUIMIENTO


--MEGUSTA
CREATE TABLE MeGustas(
	RespuestaId uniqueidentifier,
	UsuarioId uniqueidentifier,
	Existe bit default 1,

	CONSTRAINT PK_MeGustas PRIMARY KEY(RespuestaId, UsuarioId),
	CONSTRAINT FK_MeGustas_Respuestas FOREIGN KEY(RespuestaId) 
		REFERENCES Respuestas(RespuestaId),
	CONSTRAINT FK_MeGustas_Usuarios FOREIGN KEY(UsuarioId)
		REFERENCES Usuarios(UsuarioId)
)
--FIN MEGUSTA

-- --FIN INTERACCIONES-- --