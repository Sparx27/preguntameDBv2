-- Cuando un usuario da me gusta a una respuesta, NLikes en la Respuesta y NLikes Del Usuario que hizo esa respuesta, deben actualizarse
-- Es un Toggle, por lo que si no existe un MeGusta con los parametros, se crea. Y si ya existe, significa que se está quitando un MeGusta y se debe eliminar
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

-- Lógica análoga al Toggle de MeGusta. 
-- Si no existe un seguimiento con los parametros, se crea. Y si ya existe, significa que se está dejando de seguir a un Usuario y se debe eliminar el registro de Seguimientos
-- A su vez, se hacen los Updates necesarios al atributo NSeguidores de Usuario
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