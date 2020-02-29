USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[SERVICE_COMMON_GRAPH_PRINT]
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX) = NULL
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
	
		IF OBJECT_ID('tempdb..#utotal') IS NOT NULL
			DROP TABLE #utotal

		CREATE TABLE #utotal
			(
				ID				INT,
				ClientID		INT,
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
				ActualError		BIT,
				Actual			NVARCHAR(MAX),
				ComplianceError	BIT,
				Compliance		NVARCHAR(MAX),
				UpdateSkipError	BIT, 
				UpdateSkip		NVARCHAR(MAX),
				UpdateLostError	BIT,
				UpdateLost		NVARCHAR(MAX),
				UpdatePeriod	NVARCHAR(128),
				LastSearch		NVARCHAR(32),
				UF_PATH			INT,
				LastSTT			NVARCHAR(32),
				ROW_CNT			INT
			)

		INSERT INTO #utotal
			EXEC USR.SERVICE_COMMON_GRAPH @SERVICE, @BEGIN, @END, @TYPE

		SELECT 
			ID, ClientID, ClientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, 
			ResVersion, ResActual, ConsExe, ConsExeActual, Actual, ActualError,
			Compliance, ComplianceError, UpdateSkip, UpdateSkipError, UpdateLost, UpdateLostError,
			UpdatePeriod, LastSearch, LastSTT, ClientEvent,
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
					ID, ClientID, ClientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, 
					ResVersion, ResActual, ConsExe, ConsExeActual, Actual, ActualError,
					Compliance, ComplianceError, UpdateSkip, UpdateSkipError, UpdateLost, UpdateLostError,
					UpdatePeriod, LastSearch, LastSTT, ClientEvent
				FROM #utotal
			) AS a
		ORDER BY ID
		

		IF OBJECT_ID('tempdb..#utotal') IS NOT NULL
			DROP TABLE #utotal
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

