USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISCONNECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DISCONNECT]
	@CLIENT	NVARCHAR(MAX),
	@DATE	SMALLDATETIME,
	@REASON	UNIQUEIDENTIFIER,
	@STATUS	INT,
	@SYSTEM	BIT,
	@NOTE	NVARCHAR(MAX)
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

		INSERT INTO dbo.ClientDisconnect(CD_ID_CLIENT, CD_TYPE, CD_DATE, CD_ID_REASON, CD_ID_STATUS, CD_NOTE)
			SELECT ID, 1, @DATE, @REASON, @STATUS, @NOTE
			FROM dbo.TableIDFromXML(@CLIENT)

		UPDATE dbo.ClientTable
		SET StatusID = @STATUS
		WHERE ClientID IN
			(
				SELECT ID
				FROM dbo.TableIDFromXML(@CLIENT)
			) AND STATUS = 1

		DECLARE @DS_ON	UNIQUEIDENTIFIER
		DECLARE @DS_OFF	UNIQUEIDENTIFIER

		IF @SYSTEM = 1
		BEGIN
			SELECT @DS_ON = DS_ID
			FROM dbo.DistrStatus
			WHERE DS_REG = 0

			SELECT @DS_OFF = DS_ID
			FROM dbo.DistrStatus
			WHERE DS_REG = 1


			INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
				SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
				FROM dbo.ClientDistr
				WHERE ID_CLIENT IN
					(
						SELECT ID
						FROM dbo.TableIDFromXML(@CLIENT)
					) AND ID_STATUS = @DS_ON
					AND STATUS = 1

			UPDATE dbo.ClientDistr
			SET ID_STATUS	= @DS_OFF,
				OFF_DATE	= @DATE,
				BDATE		= GETDATE(),
				UPD_USER	= ORIGINAL_LOGIN()
			WHERE ID_CLIENT IN
				(
					SELECT ID
					FROM dbo.TableIDFromXML(@CLIENT)
				) AND ID_STATUS = @DS_ON
				AND STATUS = 1
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
GRANT EXECUTE ON [dbo].[CLIENT_DISCONNECT] TO rl_client_disconnect;
GO
