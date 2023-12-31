USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CHECK]
	@ID	INT
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

		IF OBJECT_ID('tempdb..#check') IS NOT NULL
			DROP TABLE #check

		CREATE TABLE #check
			(
				TP	VARCHAR(50),
				ER	VARCHAR(1000)
			)

		DECLARE @STATUS		BIT
		DECLARE @CATEGORY	BIT
		DECLARE @INN		BIT
		DECLARE @SERVICE	BIT
		DECLARE @ACTIVITY	BIT
		DECLARE	@PAPPER		BIT
		DECLARE @GRAPH		BIT

		SELECT
			@STATUS = ST_CA_STATUS, @CATEGORY = ST_CA_CATEGORY,
			@INN = ST_CA_INN, @SERVICE = ST_CA_SERVICE,
			@ACTIVITY = ST_CA_ACTIVITY, @PAPPER = ST_CA_PAPPER,
			@GRAPH = ST_CA_GRAPH
		FROM dbo.Settings
		WHERE ST_USER = ORIGINAL_LOGIN() AND ST_HOST = HOST_NAME()

		IF @STATUS = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'STATUS'

		IF @CATEGORY = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'CATEGORY'

		IF @INN = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'INN'

		IF @SERVICE = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'SERVICE_TYPE'

		IF @ACTIVITY = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'ACTIVITY'

		IF @PAPPER = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'PAPPER'

		IF @GRAPH = 1
			INSERT INTO #check(TP, ER)
				SELECT TP, ER
				FROM dbo.ClientCheckView
				WHERE ClientID = @ID AND TP = 'GRAPH'

		SELECT TP, ER
		FROM #check

		IF OBJECT_ID('tempdb..#check') IS NOT NULL
			DROP TABLE #check

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CHECK] TO rl_client_card_check;
GO
