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

	IF OBJECT_ID('tempdb..#stt') IS NOT NULL
		DROP TABLE #stt

	CREATE TABLE #stt
		(
			ID		UNIQUEIDENTIFIER PRIMARY KEY,
			FL_NAME	VARCHAR(256),
			FL_SIZE	BIGINT,
			DATE	DATETIME,
			RN		INT
		)

	INSERT INTO #stt(ID, FL_NAME, FL_SIZE, DATE, RN)
		SELECT ID, FL_NAME, FL_SIZE, DATE, RN
		FROM
			(
				SELECT ID, FL_NAME, FL_SIZE, DATE, ROW_NUMBER() OVER(PARTITION BY FL_NAME ORDER BY DATE) AS RN
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
END