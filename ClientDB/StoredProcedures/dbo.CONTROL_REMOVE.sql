USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CONTROL_REMOVE]
	@CLIENT	INT,
	@ID		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF (SELECT Maintenance.GlobalControlLogin()) = '1'
		BEGIN
			IF @ID IS NULL
				UPDATE dbo.ClientControl
				SET CC_REMOVE_DATE = GETDATE(),
					CC_REMOVER = ORIGINAL_LOGIN()
				WHERE CC_ID_CLIENT = @CLIENT
					AND CC_REMOVE_DATE IS NULL
					AND (CC_AUTHOR = ORIGINAL_LOGIN() OR IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('DBChief') = 1)
			ELSE
				UPDATE dbo.ClientControl
				SET CC_REMOVE_DATE = GETDATE(),
					CC_REMOVER = ORIGINAL_LOGIN()
				WHERE CC_ID = @ID
					AND CC_REMOVE_DATE IS NULL
					AND (CC_AUTHOR = ORIGINAL_LOGIN() OR IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('DBChief') = 1)

			IF @@ROWCOUNT = 0
				RAISERROR('��������� ������� � �������� ����� ������', 15, 1)
		END
		ELSE
		BEGIN
			IF ((SELECT TOP 1 CC_TYPE FROM dbo.ClientControl WHERE CC_ID_CLIENT = @CLIENT AND CC_REMOVE_DATE IS NULL) = 5)
				AND ((IS_MEMBER('rl_client_control_lawyer_set') <> 1 AND IS_MEMBER('db_owner') <> 1))
				RAISERROR('��������� ������� � �������� ������ �������', 15, 1)
			ELSE
			BEGIN
				IF @ID IS NULL
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
				ELSE
					UPDATE dbo.ClientControl
					SET CC_REMOVE_DATE = GETDATE(),
						CC_REMOVER = ORIGINAL_LOGIN()
					WHERE CC_ID = @ID
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
GRANT EXECUTE ON [dbo].[CONTROL_REMOVE] TO rl_client_control_remove;
GO
