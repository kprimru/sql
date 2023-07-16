USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_REMOVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_REMOVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_REMOVE]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_CONTROL_LOGIN	Bit;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_CONTROL_LOGIN = Cast([System].[Setting@Get]('CONTROL_LOGIN') AS Bit);

		IF @Setting_CONTROL_LOGIN = 1
		BEGIN
			UPDATE dbo.ClientControl
			SET CC_REMOVE_DATE = GETDATE(),
				CC_REMOVER = ORIGINAL_LOGIN()
			WHERE CC_ID_CLIENT = @CLIENT
				AND CC_REMOVE_DATE IS NULL
				AND (CC_AUTHOR = ORIGINAL_LOGIN() OR IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('DBChief') = 1)

			IF @@ROWCOUNT = 0
				RAISERROR('Запрещено снимать с контроля чужие записи', 16, 1)
		END
		ELSE
		BEGIN
			IF ((SELECT TOP 1 CC_TYPE FROM dbo.ClientControl WHERE CC_ID_CLIENT = @CLIENT AND CC_REMOVE_DATE IS NULL) = 5)
				AND (IS_MEMBER('rl_client_control_lawyer_set') <> 1)
				RAISERROR('Запрещено снимать с контроля записи Юристов', 16, 1)
			ELSE
			BEGIN
				UPDATE dbo.ClientControl
				SET CC_REMOVE_DATE = GETDATE(),
					CC_REMOVER = ORIGINAL_LOGIN()
				WHERE CC_ID_CLIENT = @CLIENT
					AND CC_REMOVE_DATE IS NULL
					AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
					AND
						(
							CC_TYPE = 5
							AND IS_MEMBER('rl_client_control_lawyer_set') = 1

							OR

							CC_TYPE <> 5
							AND IS_MEMBER('rl_client_control_lawyer_set') = 0

							OR

							IS_MEMBER('db_owner') = 1
						)

				IF @@ROWCOUNT = 0
					UPDATE dbo.ClientControl
					SET CC_REMOVE_DATE = GETDATE(),
						CC_REMOVER = ORIGINAL_LOGIN()
					WHERE CC_ID_CLIENT = @CLIENT
						AND CC_REMOVE_DATE IS NULL
						--AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
						AND
							(
								CC_TYPE = 5
								AND IS_MEMBER('rl_client_control_lawyer_set') = 1

								OR

								CC_TYPE <> 5
								AND IS_MEMBER('rl_client_control_lawyer_set') = 0

								OR

								IS_MEMBER('db_owner') = 1
							)
			END
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
