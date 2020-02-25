USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[STT_OLD_SELECT]
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

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt

		CREATE TABLE #stt
			(
				FL_NAME	VARCHAR(256),
				FL_SIZE	BIGINT,
				DATE	DATETIME,
				RN		INT,
				PRIMARY KEY CLUSTERED(FL_NAME, DATE)
			)

		INSERT INTO #stt(FL_NAME, FL_SIZE, DATE, RN)
			SELECT FL_NAME, FL_SIZE, DATE, RN
			FROM
				(
					SELECT FL_NAME, FL_SIZE, DATE, ROW_NUMBER() OVER(PARTITION BY FL_NAME ORDER BY DATE) AS RN
					FROM dbo.ClientStat
				) AS o_O
			WHERE RN > @LAST_COUNT
				AND DATE < @MIN_DATE
			
		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (FL_NAME) INCLUDE (DATE)'
		EXEC (@SQL)

		IF @MODE = 1
			SELECT *
			FROM #stt
			ORDER BY FL_NAME, DATE DESC
		ELSE IF @MODE = 2
			SELECT DISTINCT
				FL_NAME,
				(
					SELECT COUNT(*)
					FROM #stt b
					WHERE a.FL_NAME = b.FL_NAME
				) AS FL_COUNT,
				(
					SELECT SUM(FL_SIZE)
					FROM #stt b
					WHERE a.FL_NAME = b.FL_NAME
				) AS FL_SIZE
			FROM 
				#stt a			
			ORDER BY FL_NAME

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END