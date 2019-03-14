USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[USER_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#user') IS NOT NULL
		DROP TABLE #user

	CREATE TABLE #user
		(
			UserName VARCHAR(100),
			GroupName VARCHAR(100),
			LoginName VARCHAR(100),
			DefDBName VARCHAR(100),
			DefSchemaName VARCHAR(100),
			UserID INT,
			SID VARBINARY(1000)
		)

	INSERT INTO #user 
		EXEC sp_helpuser

	SELECT DISTINCT UserName
	FROM #user
	WHERE UserName NOT IN 
		(
			SELECT 'dbo'
			UNION ALL
			SELECT 'sys'
			UNION ALL
			SELECT 'guest'
			UNION ALL
			SELECT 'INFORMATION_SCHEMA'		
		)
	ORDER BY UserName

	IF OBJECT_ID('tempdb..#user') IS NOT NULL
		DROP TABLE #user
END