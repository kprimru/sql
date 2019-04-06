USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[LOCK_SELECT]
	@RC INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @sql VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	CREATE TABLE #temp
		(
			LC_ID UNIQUEIDENTIFIER,
			REF_NAME VARCHAR(50),
			REF_VALUE VARCHAR(50)		
		)

	DECLARE r CURSOR LOCAL FOR
		SELECT DISTINCT LC_ID_DATA 
		FROM Common.Locks

	OPEN r

	DECLARE @lockdata UNIQUEIDENTIFIER

	FETCH NEXT FROM r INTO @lockdata

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			@sql = 'INSERT INTO #temp SELECT LC_ID, ''' + REF_TITLE + ''', ' + REF_VAL + ' AS DAT_CAPTION' +
			' 
			FROM Common.Locks INNER JOIN ' + REF_SCHEMA + '.' + REF_VIEW + ' ON ' + REF_KEY + ' = LC_RECORD
			WHERE LC_ID_DATA = ''' + CONVERT(VARCHAR(50), @lockdata) + ''''
		FROM Meta.Reference
		WHERE REF_ID = @lockdata
	
		--SELECT @sql
		EXEC (@sql)
	
		FETCH NEXT FROM r INTO @lockdata
	END

	CLOSE r
	DEALLOCATE r

	SELECT b.LC_ID, a.REF_NAME, a.REF_VALUE, LC_LOCK_TIME, LC_LOGIN, LC_HOST, LC_LOGIN_TIME, LC_NT_USER, LC_SPID
	FROM 
		#temp a INNER JOIN
		Common.Locks b ON a.LC_ID = b.LC_ID
	ORDER BY REF_NAME, LC_LOCK_TIME DESC

	SELECT @RC = @@ROWCOUNT

	DROP TABLE #temp
	
END
