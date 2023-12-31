USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_PROTOCOL_FILTER]
	@HST_ID		SMALLINT,
	@DIS_NUM	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@OPER		VARCHAR(MAX),
	@USER		VARCHAR(MAX),
	@COMPUTER	VARCHAR(MAX),
	@TEXT		VARCHAR(150),
	@LAST		DATETIME = NULL OUTPUT
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

		SELECT @LAST = MAX(RPR_INSERT)
		FROM dbo.RegProtocol

		IF OBJECT_ID('tempdb..#oper') IS NOT NULL
			DROP TABLE #oper
		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user
		IF OBJECT_ID('tempdb..#comp') IS NOT NULL
			DROP TABLE #comp

		CREATE TABLE #oper
			(
				OPER_NAME VARCHAR(64) PRIMARY KEY
			)

		IF @OPER IS NOT NULL
			INSERT INTO #oper(OPER_NAME)
				SELECT Item
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@OPER, ',')
		ELSE
			INSERT INTO #oper(OPER_NAME)
				SELECT DISTINCT RPR_OPER
				FROM dbo.RegProtocol

		CREATE TABLE #user
			(
				US_NAME VARCHAR(64) PRIMARY KEY
			)

		IF @USER IS NOT NULL
			INSERT INTO #user(US_NAME)
				SELECT ISNULL(Item, '')
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@USER, ',')
		ELSE
			INSERT INTO #user(US_NAME)
				SELECT DISTINCT ISNULL(RPR_USER, '')
				FROM dbo.RegProtocol

		CREATE TABLE #comp
			(
				COMP_NAME VARCHAR(64) PRIMARY KEY
			)

		IF @COMPUTER IS NOT NULL
			INSERT INTO #comp(COMP_NAME)
				SELECT Item
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@COMPUTER, ',')
		ELSE
			INSERT INTO #comp(COMP_NAME)
				SELECT DISTINCT ISNULL(RPR_COMPUTER, '')
				FROM dbo.RegProtocol


		SET @END = DATEADD(DAY, 1, @END)

		SELECT
			RPR_DATE,
			HST_SHORT + ' ' + CONVERT(VARCHAR(20), RPR_DISTR) +
			CASE RPR_COMP
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), RPR_COMP)
			END AS DIS_STR,
			RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT,
			RPR_USER, RPR_COMPUTER, RPR_INSERT
		FROM
			dbo.RegProtocol
			INNER JOIN dbo.HostTable ON HST_ID = RPR_ID_HOST
			INNER JOIN #oper ON OPER_NAME = RPR_OPER
			INNER JOIN #user ON US_NAME = RPR_USER
			INNER JOIN #comp ON COMP_NAME = RPR_COMPUTER
		WHERE (HST_ID = @HST_ID OR @HST_ID IS NULL)
			AND (RPR_DISTR = @DIS_NUM OR @DIS_NUM IS NULL)
			AND (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (RPR_DATE < @END OR @END IS NULL)
			AND (RPR_TEXT LIKE @TEXT OR @TEXT IS NULL)
		ORDER BY RPR_DATE DESC, RPR_DISTR

		IF OBJECT_ID('tempdb..#oper') IS NOT NULL
			DROP TABLE #oper
		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user
		IF OBJECT_ID('tempdb..#comp') IS NOT NULL
			DROP TABLE #comp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_PROTOCOL_FILTER] TO rl_reg_protocol_r;
GO
