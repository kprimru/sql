USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EVENT_FILTER_2]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@CLIENT		NVARCHAR(256),
	@TYPE		NVARCHAR(MAX),
	@SERVICE	INT,
	@AUTHOR		NVARCHAR(MAX),
	@WORDS		NVARCHAR(MAX),
	@CATEGORY	NVARCHAR(MAX)
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

		IF @START IS NULL
			SET @START = dbo.DateOf(DATEADD(MONTH, -2, GETDATE()))

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		CREATE TABLE #words
			(
				WRD	VARCHAR(100) PRIMARY KEY
			)
				
		INSERT INTO #words(WRD)
			SELECT DISTINCT '%' + Word + '%'
			FROM dbo.SplitString(@WORDS)
			WHERE Word IS NOT NULL
			
		SELECT
			c.ClientID, EventDate, c.ClientFullName, ServiceName, ManagerName, ServiceStatusIndex, CATEGORY = ClientTypeName, EventTypeName, EventComment,
			EventCreateUser AS EventCreateData, 
			CASE
				WHEN EventLastUpdate <> EventCreate THEN EventLastUpdateUser 
				ELSE ''
			END AS EventlastUpdateData
		FROM
			[dbo].[ClientList@Get?Read]() a
			INNER JOIN dbo.EventTable b ON a.WCL_ID = b.CLientID
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ClientID = c.ClientID
			INNER JOIN dbo.ClientTable d ON c.ClientID = d.ClientID
			INNER JOIN dbo.EventTypeTable e ON e.EventTypeID = b.EventTypeID
			INNER JOIN dbo.ClientTypeTable t ON t.ClientTypeID = d.ClientTypeID
		WHERE /*EventID = MasterID
			AND */EventActive = 1
			AND (EventDate >= @START OR @START IS NULL)
			AND (EventDate <= @FINISH OR @FINISH IS NULL)
			AND (c.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (@TYPE IS NULL OR b.EventTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)))
			AND (@AUTHOR IS NULL OR b.EventCreateUser IN (SELECT ID FROM dbo.TableStringFromXML(@AUTHOR)))
			AND (@CATEGORY IS NULL OR d.ClientTypeId IN (SELECT ID FROM dbo.TableIdFromXML(@CATEGORY)))
			AND NOT EXISTS
				(
					SELECT *
					FROM #words
					WHERE NOT (EventComment LIKE WRD)
				)	
		ORDER BY EventDate DESC, EventID DESC
			
		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
