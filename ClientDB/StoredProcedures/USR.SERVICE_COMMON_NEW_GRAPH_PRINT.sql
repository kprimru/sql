USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[SERVICE_COMMON_NEW_GRAPH_PRINT]
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID('tempdb..#utotal') IS NOT NULL
		DROP TABLE #utotal

	CREATE TABLE #utotal
		(
			ID				INT,
			ClientID		INT,
			Complect		VarCHar(100),
			ComplectStr		VarCHar(100),
			CLientFullName	NVARCHAR(512),
			SystemList		NVARCHAR(512),
			ClientTypeName	NVARCHAR(16),
			ServiceType		NVARCHAR(16),
			ServiceDay		NVARCHAR(32),
			DayOrder		INT,
			DayTime			SMALLDATETIME,
			ClientEvent		NVARCHAR(MAX),
			UpdateDayTime	NVARCHAR(64),
			UpdateDay		INT,
			ResVersion		NVARCHAR(64),
			ConsExe			NVARCHAR(64),
			ResActual		BIT,
			ConsExeActual	BIT,
			UpdateDateTime	SMALLDATETIME,
			ComplianceError	BIT,
			Compliance		NVARCHAR(MAX),
			UpdateSkipError	BIT, 
			UpdateSkip		NVARCHAR(MAX),
			UpdateLostError	BIT,
			UpdateLost		NVARCHAR(MAX),
			UpdatePeriod	NVARCHAR(128),
			UF_PATH			INT,
			LastSTT			NVARCHAR(32),
			ROW_CNT			INT
		)

	INSERT INTO #utotal
		EXEC USR.SERVICE_COMMON_NEW_GRAPH @SERVICE, @BEGIN, @END, @TYPE

	SELECT 
		ID, ClientID, ComplectStr, ClientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, 
		ResVersion, ResActual, ConsExe, ConsExeActual, Compliance, ComplianceError, UpdateSkip, UpdateSkipError, 
		UpdateLost, UpdateLostError, UpdatePeriod, LastSTT, ClientEvent,
		REPLACE(REVERSE(STUFF(REVERSE(
			(
				SELECT CASE UF_PATH WHEN 1 THEN UpdateDayTime ELSE '' END + '|'
				FROM
					#utotal z
				WHERE z.ID = a.ID
				ORDER BY UpdateDateTime FOR XML PATH('')
			)), 1, 1, '')), '|', CHAR(10)) AS Updates,
		REPLACE(REVERSE(STUFF(REVERSE(
			(
				SELECT CASE UF_PATH WHEN 3 THEN UpdateDayTime ELSE '' END + '|'
				FROM
					#utotal z
				WHERE z.ID = a.ID
				ORDER BY UpdateDateTime FOR XML PATH('')
			)), 1, 1, '')), '|', CHAR(10)) AS UpdatesControl
	FROM
		(
			SELECT DISTINCT 
				ID, ClientID, Complect, ComplectStr, ClientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, 
				ResVersion, ResActual, ConsExe, ConsExeActual, Compliance, ComplianceError, UpdateSkip, UpdateSkipError, 
				UpdateLost, UpdateLostError,UpdatePeriod, LastSTT, ClientEvent
			FROM #utotal
		) AS a
	ORDER BY ID
	

	IF OBJECT_ID('tempdb..#utotal') IS NOT NULL
		DROP TABLE #utotal
END
