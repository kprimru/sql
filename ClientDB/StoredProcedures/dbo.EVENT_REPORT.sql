USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EVENT_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		INT,
	@TYPE		VARCHAR(MAX),
	@SERV_STR	VARCHAR(150) = NULL OUTPUT
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

		IF @SERVICE IS NOT NULL
			SELECT @SERV_STR = ServiceName + '(' + ManagerName + ')'
			FROM dbo.ServiceTable a INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
			WHERE ServiceID = @SERVICE
		ELSE IF @MANAGER IS NOT NULL
			SELECT @SERV_STR = ManagerName
			FROM dbo.ManagerTable
			WHERE ManagerID = @MANAGER
		ELSE
			SELECT @SERV_STR = ''

		SELECT 
			ClientFullName, ServiceTypeShortName,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemShortName + ','
					FROM 
						dbo.ClientDistrView z WITH(NOEXPAND)										
					WHERE DS_REG = 0
						AND z.ID_CLIENT = a.ClientID
					ORDER BY SystemOrder FOR XML PATH('')
				)
			), 1, 1, '')) AS SystemList,
			CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment AS EventText
		FROM
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
			INNER JOIN (SELECT Item FROM dbo.GET_TABLE_FROM_LIST(@TYPE, ',')) o_O ON a.ServiceTypeID = Item		
			LEFT OUTER JOIN dbo.EventTable c ON c.ClientID = a.ClientID AND EventActive = 1 AND EventDate BETWEEN @BEGIN AND @END
		WHERE a.ServiceStatusID = @STATUS
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, EventDate DESC, EventID DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END