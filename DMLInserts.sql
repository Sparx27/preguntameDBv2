INSERT INTO Paises VALUES
('URU', 'Uruguay'),
('ARG', 'Argentina'),
('MEX', 'M�xico'),
('PER', 'Per�'),
('COL', 'Colombia'),
('ESP', 'Espa�a')


INSERT INTO Usuarios
	(UsuarioId, Confirmado, Activo, Email, NombreUsuario, Contrasena, Nombre, Apellido, PaisId)
VALUES
	('1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 1, 1, 'fer25de25prueba252@gmail.com', 'fer25', 'Prueba123', 'Fernando', 'P�rez', 'URU'),
	('C1D151D6-32EB-462E-9163-B62420940AA3', 1, 1, 'sof25de25prueba252@gmail.com', 'sof25', 'Prueba123', 'Sof�a', 'Martinez', 'URU'),
	('DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 1, 1, 'san25de25prueba252@gmail.com', 'sanben', 'Prueba123', 'Santiago', 'Benites', 'URU'),
	('7D8E65EA-AE06-4994-A962-EC04468A23DB', 1, 1, 'vic25de25prueba252@gmail.com', 'vicu', 'Prueba123', 'Victoria', 'Correa', 'ARG'),
	('984296BE-CFB8-4F07-868C-88E68B09C76F', 1, 1, 'jho25de25prueba252@gmail.com', 'jdoe', 'Prueba123', 'Jhon', 'Doe', 'ESP')




INSERT INTO Preguntas(PreguntaId, Usuario_Envia, Usuario_Recibe, Dsc) VALUES
(
	'F634F9CF-C3CA-4324-950A-C21A42D0E0AA', 
	'C1D151D6-32EB-462E-9163-B62420940AA3', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'�Qu� libro o pel�cula te ha impactado m�s en la vida?'
),
(
	'F4F09A97-87BB-485C-AF6F-D32B39E8A68F', 
	null, '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'�Cu�l es tu lugar favorito para viajar y por qu�?'
),
(
	'835C7FF3-7BD3-4DD3-84FA-77023332BDFF',
	'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', '1FD2C01B-F0C8-48F7-AFD1-67563ADC071A', 
	'�Qu� habilidad te gustar�a aprender si tuvieras tiempo y recursos ilimitados?'
),
(
	'C6D87D6D-1872-4626-AC50-5DEF28087963', 
	null, 'C1D151D6-32EB-462E-9163-B62420940AA3', 
	'Si pudieras cenar con cualquier persona, viva o no, �qui�n ser�a y qu� le preguntar�as?'
),
(
	'22105A04-A4BB-4A53-9676-BCA3763C5BEB', 
	null, '984296BE-CFB8-4F07-868C-88E68B09C76F', 
	'�Cu�l es tu recuerdo m�s preciado de la infancia?'
),
(
	'4ECD7A23-7688-4977-A2AE-D9687130BFAF',
	'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 'C1D151D6-32EB-462E-9163-B62420940AA3', 
	'�Qu� consejo le dar�as a tu yo m�s joven si pudieras?'
),
(
	'1B84271B-72D8-4CD3-B57A-3752A21490C0', 
	'7D8E65EA-AE06-4994-A962-EC04468A23DB', 'DCC4BFC3-CA7D-4904-BDE9-D65A8C85FC7F', 
	'�Cu�l es tu plato favorito y qu� lo hace especial para ti?'
)


INSERT INTO Respuestas(RespuestaId, PreguntaId, Dsc) VALUES
(
	'B97CFFF5-2FF4-4D71-9B28-38E62EDB2B8D',
	'F4F09A97-87BB-485C-AF6F-D32B39E8A68F', 'Me encanta Jap�n por su mezcla de tradici�n y modernidad.'
),
(
	'D44DF95C-4CB6-4B5C-978C-CFDECD79CB73',
	'F634F9CF-C3CA-4324-950A-C21A42D0E0AA', '"�tica a Nic�maco" de Arist�teles, lo recomiendo.'
),
(
	'EF73DC4E-7B29-4B73-845D-7B4066CD2CB9', 
	'C6D87D6D-1872-4626-AC50-5DEF28087963', 'Cenar�a con Albert Einstein y le preguntar�a sobre su proceso creativo.'
),
(
	'A50E8B78-43A2-4230-A53E-D0D534306BFA', 
	'22105A04-A4BB-4A53-9676-BCA3763C5BEB', 'Jugar en el campo con mis amigos durante el verano.'
),
(
	'32CCA49F-F83B-40A2-8BD0-B5F22DDD56F7', 
	'4ECD7A23-7688-4977-A2AE-D9687130BFAF', 'Todo lo bueno que quieras lograr en la vida, va a requerir en menor o mayor medida de tu autodisciplina.'
)

UPDATE Preguntas
SET Estado = 1
WHERE Preguntas.PreguntaId IN (
	select p.PreguntaId
	from Preguntas p
	join Respuestas r on r.PreguntaId = p.PreguntaId
)


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

UPDATE Usuarios
SET NSeguidores = (
	select count(s.Usuario_Seguido)
	from Seguimientos s
	where s.Usuario_Seguido = Usuarios.UsuarioId
)

select * from Usuarios
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

UPDATE Usuarios
SET NLikes = (
	select count(m.UsuarioId)
	from MeGustas m
	where m.UsuarioId = Usuarios.UsuarioId
)

UPDATE Respuestas
SET NLikes = (
	select count(m.RespuestaId)
	from MeGustas m
	where m.RespuestaId = Respuestas.RespuestaId
)
