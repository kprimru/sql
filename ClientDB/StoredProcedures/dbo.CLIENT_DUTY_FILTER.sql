USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_FILTER]
	@begin SMALLDATETIME,
	@end SMALLDATETIME,
	@calltypeid VARCHAR(MAX) = NULL,
	@dutyid VARCHAR(100) = NULL,
	@complete BIT = NULL,
	@comment VARCHAR(1000) = null,
	@serviceid int = null,
	@system int = null,
	@npo	bit = null,
	@direction	uniqueidentifier = null,
	@noresult bit = null,
	@category TinyInt = null,
	@link int = null
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

		SET @end = DATEADD(DAY, 1, @end)

		SELECT
			a.ClientID, ClientFullName,
			Convert(varchar(20), Convert(datetime, ClientDutyDateTime, 112), 104) as ClientDutyDateStr,
			DutyName, CallTypeName, ClientDutyDocs, ClientDutyComment,
			ServiceName, ManagerName AS ClientManagerName,
			REVERSE(STUFF(REVERSE((
			SELECT SystemShortName + ', '
			FROM
				dbo.ClientDutyIBTable INNER JOIN
				dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
			WHERE a.ClientDutyID = ClientDutyIBTable.ClientDutyID
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS IBList,
		REVERSE(STUFF(REVERSE((
			SELECT SystemShortName + ', '
			FROM
				dbo.ClientDistrView WITH(NOEXPAND)
			WHERE ID_CLIENT = b.ClientID AND DS_REG = 0
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS SystemList,
		REVERSE(STUFF(REVERSE((
			SELECT Convert(VARCHAR(10), SystemTable.SystemID) + ', '
			FROM
				dbo.ClientDutyIBTable INNER JOIN
				dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
			WHERE a.ClientDutyID = ClientDutyIBTable.ClientDutyID
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS CheckedIB,
			ClientDutyGive,
			ISNULL(ClientDutySurname + ' ' + ClientDutyName + ' ' + ClientDutyPatron, ClientDutyContact) AS ClientDutyContact,
			--ClientDutySurname + ' ' + ClientDutyName + ' ' + ClientDutyPatron AS ClientDutyContact,
			ClientDutyPos, ClientDutyQuest,
			ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyUncomplete,
			ClientDutyAnswer, g.NAME AS DIR_NAME
		FROM
			[dbo].[ClientList@Get?Read]()
			INNER JOIN dbo.ClientDutyTable a ON WCL_ID = ClientID
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID
			INNER JOIN dbo.ServiceTable d ON d.ServiceID = b.ClientServiceID
			INNER JOIN dbo.ManagerTable e ON e.ManagerID = d.ManagerID
			LEFT OUTER JOIN dbo.CallTypeTable f ON f.CallTypeID = a.CallTypeID
			LEFT OUTER JOIN dbo.CallDirection g ON g.ID = a.ID_DIRECTION
		WHERE
			a.STATUS = 1
			AND (ClientDutyDateTime < @end or @end IS NULL)
			AND (ClientDutyDateTime >= @begin or @begin IS NULL)
			AND (c.DutyID = @dutyid OR @dutyid IS NULL)
			AND (ClientDutyComplete = @complete OR @complete IS NULL)
			AND (f.CallTypeID IN (SELECT Item FROM dbo.GET_TABLE_FROM_LIST(@calltypeid, ',')) OR @calltypeid IS NULL OR @calltypeid = '')
			AND (ClientDutyComment LIKE @comment OR ClientDutyQuest LIKE @comment OR @comment IS NULL)
			AND (ClientServiceID = @serviceid OR @serviceid IS NULL)
			AND (ID_DIRECTION = @DIRECTION OR @DIRECTION IS NULL)
			AND	(	EXISTS(
							SELECT *
							FROM dbo.ClientDutyIBTable z
							WHERE z.ClientDutyID = a.ClientDutyID
								AND SystemID = @system
						) OR @system is null
				)
			AND (@npo IS NULL OR ClientDutyNPO = @NPO)
			AND (@noresult IS NULL OR @noresult = 0 OR @noresult = 1 AND NOT EXISTS(SELECT * FROM dbo.ClientDutyResult z WHERE z.STATUS = 1 AND z.ID_DUTY = a.ClientDutyID))
			AND (b.ClientTypeID = @category OR @category IS NULL)
			AND (@link IS NULL OR @LINK = 0 OR @LINK = 1 AND LINK = 1 OR @LINK = 2 AND LINK = 0)
		ORDER BY ClientDutyDateTime DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_FILTER] TO rl_filter_duty;
GO
