USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_ADD]  AS SELECT 1')
GO

/*
Автор:         Денисов Алексей
Описание:      Добавить дистрибутив клиенту
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_ADD]
	@clientid INT,
	@distrid INT,
	@registerdate SMALLDATETIME,
	@systemserviceid SMALLINT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO dbo.ClientDistrTable(CD_ID_CLIENT, CD_ID_DISTR, CD_REG_DATE, CD_ID_SERVICE)
		VALUES (@clientid, @distrid, @registerdate, @systemserviceid)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_ADD] TO rl_client_distr_w;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_ADD] TO rl_client_w;
GO
