USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_CONNECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_CONNECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_DISTR_CONNECT]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME
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

		DECLARE @STATUS UNIQUEIDENTIFIER

		SELECT @STATUS = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 0

		IF (SELECT ID_STATUS FROM dbo.ClientDistr WHERE ID = @ID) = @STATUS
		BEGIN
			RAISERROR('Дистрибутив уже подключен к сопровождению. Операция отменена', 16, 1)
			RETURN
		END

		INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
			FROM dbo.ClientDistr
			WHERE ID = @ID

		UPDATE dbo.ClientDistr
		SET ID_STATUS	= @STATUS,
			ON_DATE		= @DATE,
			BDATE		= GETDATE(),
			UPD_USER	= ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_CONNECT] TO rl_client_distr_connect;
GO
