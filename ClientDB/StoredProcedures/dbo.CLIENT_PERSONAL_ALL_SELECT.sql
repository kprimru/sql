USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_ALL_SELECT]
	@CLIENT	INT
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

		IF OBJECT_ID('tempdb..#tmp_pers') IS NOT NULL
			DROP TABLE #tmp_pers

		CREATE TABLE #tmp_pers
			(
				SURNAME	NVARCHAR(256),
				NAME	NVARCHAR(256),
				PATRON	NVARCHAR(256),
				POS		NVARCHAR(256),
				FRM		NVARCHAR(64),
				FIO		NVARCHAR(512),
				PHONE	NVARCHAR(256),
				DATE	DATETIME
			)

		INSERT INTO #tmp_pers
			EXEC dbo.CLIENT_PERSONAL_OTHER_SELECT @CLIENT

		SELECT
			CASE ISNULL(CP_SURNAME, '')
				WHEN '' THEN ''
				ELSE CP_SURNAME + ' '
			END + 
			CASE ISNULL(CP_NAME, '')
				WHEN '' THEN ''
				ELSE CP_NAME + ' '
			END +
			ISNULL(CP_PATRON, '') CP_FIO,
			CP_SURNAME, CP_NAME, CP_PATRON,
			CP_POS,
			CP_PHONE,
			CP_EMAIL,
			ISNULL(CPT_REQUIRED, 0) AS CPT_REQURED, CPT_ORDER, CP_ID
		FROM
			dbo.ClientPersonal
			LEFT OUTER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
		WHERE CP_ID_CLIENT = @CLIENT

		UNION ALL

		SELECT FIO, SURNAME, NAME, PATRON, POS, PHONE, '', 0, 0, NULL
		FROM #tmp_pers

		ORDER BY ISNULL(CPT_REQUIRED, 0) DESC, CPT_ORDER, CP_ID, CP_SURNAME, CP_NAME

		IF OBJECT_ID('tempdb..#tmp_pers') IS NOT NULL
			DROP TABLE #tmp_pers

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ALL_SELECT] TO rl_client_card;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ALL_SELECT] TO rl_client_list;
GO
