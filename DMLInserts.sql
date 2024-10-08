INSERT INTO Paises VALUES
('URU', 'Uruguay'),
('ARG', 'Argentina'),
('MEX', 'México'),
('PER', 'Perú'),
('COL', 'Colombia'),
('ESP', 'España')


INSERT INTO Usuarios
	(Confirmado, Activo, Email, Contrasena, Nombre, Apellido, PaisId)
VALUES
	(1, 1, 'fer25de25prueba252@gmail.com', 'Prueba123', 'Fernando', 'Pérez', 'URU'),
	(1, 1, 'sof25de25prueba252@gmail.com', 'Prueba123', 'Sofía', 'Martinez', 'URU'),
	(1, 1, 'san25de25prueba252@gmail.com', 'Prueba123', 'Santiago', 'Benites', 'URU'),
	(1, 1, 'vic25de25prueba252@gmail.com', 'Prueba123', 'Victoria', 'Correa', 'ARG'),
	(1, 1, 'jho25de25prueba252@gmail.com', 'Prueba123', 'Jhon', 'Doe', 'ESP')


INSERT INTO Preguntas(Usuario_Envia, Usuario_Recibe, Dsc) VALUES
('650700AF-1D90-4BA6-A465-07173F606EB6', 'BBAFDD56-A5DD-4118-A640-00CD9B773FEA', '¿Qué libro o película te ha impactado más en la vida?'),
(null, 'BBAFDD56-A5DD-4118-A640-00CD9B773FEA', '¿Cuál es tu lugar favorito para viajar y por qué?'),
('BBAFDD56-A5DD-4118-A640-00CD9B773FEA', '0CA525FA-E384-4317-98B8-0C3E18485796', '¿Qué habilidad te gustaría aprender si tuvieras tiempo y recursos ilimitados?'),
(null, '650700AF-1D90-4BA6-A465-07173F606EB6', 'Si pudieras cenar con cualquier persona, viva o no, ¿quién sería y qué le preguntarías?'),
(null, '9D021FE3-15A5-4C35-ADE1-324D5B16669D', '¿Cuál es tu recuerdo más preciado de la infancia?'),
('0CA525FA-E384-4317-98B8-0C3E18485796', '8D7C73E8-620F-421C-963F-3968200E8EE7', '¿Qué consejo le darías a tu yo más joven si pudieras?'),
('BBAFDD56-A5DD-4118-A640-00CD9B773FEA', '650700AF-1D90-4BA6-A465-07173F606EB6', '¿Cuál es tu plato favorito y qué lo hace especial para ti?')


INSERT INTO Respuestas(PreguntaId, Dsc) VALUES
('23BF21C6-B9DE-403C-A1ED-A19D8A5B8960', 'Me encanta Japón por su mezcla de tradición y modernidad.'),
('66251F93-580A-45F0-A986-3EF2256D9206', '"Ética a Nicómaco" de Aristóteles, lo recomiendo.'),
('9E576215-342E-4FB9-A541-D1FD2B912DCE', 'Cenaría con Albert Einstein y le preguntaría sobre su proceso creativo.'),
('B0CB0AAB-BD30-4A40-83AA-DDD3DC925A3B', 'Jugar en el campo con mis amigos durante el verano.'),
('D00E5457-FD5D-4EC4-9184-6D579B137458', 'Todo lo bueno que quieras lograr en la vida, va a requerir en menor o mayor medida de tu autodisciplina.')

UPDATE Preguntas
SET Estado = 1
WHERE Preguntas.PreguntaId IN (
	select p.PreguntaId
	from Preguntas p
	join Respuestas r on r.PreguntaId = p.PreguntaId
)


INSERT INTO Seguimientos(Usuario_Seguido, Usuario_Seguidor) VALUES
('9D021FE3-15A5-4C35-ADE1-324D5B16669D', 'BBAFDD56-A5DD-4118-A640-00CD9B773FEA'),
('9D021FE3-15A5-4C35-ADE1-324D5B16669D', '650700AF-1D90-4BA6-A465-07173F606EB6'),
('9D021FE3-15A5-4C35-ADE1-324D5B16669D', '8D7C73E8-620F-421C-963F-3968200E8EE7'),
('9D021FE3-15A5-4C35-ADE1-324D5B16669D', '0CA525FA-E384-4317-98B8-0C3E18485796'),
('0CA525FA-E384-4317-98B8-0C3E18485796', '9D021FE3-15A5-4C35-ADE1-324D5B16669D'),
('8D7C73E8-620F-421C-963F-3968200E8EE7', '9D021FE3-15A5-4C35-ADE1-324D5B16669D'),
('650700AF-1D90-4BA6-A465-07173F606EB6', '9D021FE3-15A5-4C35-ADE1-324D5B16669D'),
('650700AF-1D90-4BA6-A465-07173F606EB6', 'BBAFDD56-A5DD-4118-A640-00CD9B773FEA'),
('650700AF-1D90-4BA6-A465-07173F606EB6', '8D7C73E8-620F-421C-963F-3968200E8EE7')

UPDATE Usuarios
SET NSeguidores = (
	select count(s.Usuario_Seguido)
	from Seguimientos s
	where s.Usuario_Seguido = Usuarios.UsuarioId
)


INSERT INTO MeGustas(RespuestaId, UsuarioId) VALUES
('27A6A551-08B1-49A4-BA8C-8F5ABDAB1200', '650700AF-1D90-4BA6-A465-07173F606EB6'),
('A924F496-49D3-452A-84D6-42BEF361A1F1', 'BBAFDD56-A5DD-4118-A640-00CD9B773FEA'),
('A924F496-49D3-452A-84D6-42BEF361A1F1', '0CA525FA-E384-4317-98B8-0C3E18485796'),
('4C54D25A-0FCC-4AA7-BE02-CB998C48A640', '9D021FE3-15A5-4C35-ADE1-324D5B16669D'),
('4C54D25A-0FCC-4AA7-BE02-CB998C48A640', '8D7C73E8-620F-421C-963F-3968200E8EE7'),
('1655C41C-B84C-4FCF-AEF0-B932AC877F2F', '9D021FE3-15A5-4C35-ADE1-324D5B16669D'),
('4C54D25A-0FCC-4AA7-BE02-CB998C48A640', '0CA525FA-E384-4317-98B8-0C3E18485796'),
('27A6A551-08B1-49A4-BA8C-8F5ABDAB1200', '0CA525FA-E384-4317-98B8-0C3E18485796'),
('27A6A551-08B1-49A4-BA8C-8F5ABDAB1200', '8D7C73E8-620F-421C-963F-3968200E8EE7'),
('1655C41C-B84C-4FCF-AEF0-B932AC877F2F', '0CA525FA-E384-4317-98B8-0C3E18485796')

UPDATE Usuarios
SET NLikes = (
	select count(m.UsuarioId)
	from MeGustas m
	where m.UsuarioId = Usuarios.UsuarioId
)
