USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[USR_OLD_SELECT]
	@LAST_COUNT	SMALLINT,
	@MIN_DATE	SMALLDATETIME,
	@MODE		TINYINT
WITH EXECUTE AS OWNER
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

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		CREATE TABLE #usr
			(
				UF_ID			INT PRIMARY KEY,
				UF_DATE			SMALLDATETIME,
				UF_ID_COMPLECT	INT,
				RN				INT
			)

		INSERT INTO #usr (UF_ID, UF_DATE, UF_ID_COMPLECT, RN)
			SELECT UF_ID, UF_DATE, UF_ID_COMPLECT, RN
			FROM
				(
					SELECT UF_ID, UF_DATE, UF_ID_COMPLECT, ROW_NUMBER() OVER(PARTITION BY UF_ID_COMPLECT ORDER BY UF_DATE, UF_CREATE) AS RN
					FROM USR.USRFile
				) AS o_O
			WHERE RN > @LAST_COUNT
				AND UF_DATE < @MIN_DATE

		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (UF_ID_COMPLECT) INCLUDE (UF_DATE)'
		EXEC (@SQL)

		IF @MODE = 1
			SELECT *
			FROM #usr
			ORDER BY UF_ID_COMPLECT, UF_DATE DESC
		ELSE IF @MODE = 2
			SELECT DISTINCT
				dbo.DistrString(SystemShortName, UD_DISTR, UD_COMP) AS UD_NAME,
				(
					SELECT COUNT(*)
					FROM #usr b
					WHERE a.UF_ID_COMPLECT = b.UF_ID_COMPLECT
				) AS UD_COUNT,
				(
					SELECT MIN(UF_DATE)
					FROM #usr b
					WHERE a.UF_ID_COMPLECT = b.UF_ID_COMPLECT
				) AS UD_MIN,
				(
					SELECT MAX(UF_DATE)
					FROM #usr b
					WHERE a.UF_ID_COMPLECT = b.UF_ID_COMPLECT
				) AS UD_MAX
			FROM
				#usr a
				INNER JOIN USR.USRActiveView b ON b.UD_ID = a.UF_ID_COMPLECT
				INNER JOIN dbo.SystemTable s ON s.SystemID = b.UF_ID_SYSTEM
			ORDER BY UD_COUNT DESC, UD_NAME

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Maintenance].[USR_OLD_SELECT] TO rl_maintenance;
GO