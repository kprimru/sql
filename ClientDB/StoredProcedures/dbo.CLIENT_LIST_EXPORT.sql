USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_LIST_EXPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_LIST_EXPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_LIST_EXPORT]
	@LIST	VARCHAR(MAX)
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

		SELECT
			ROW_NUMBER() OVER(ORDER BY ClientFullName) AS CL_NUM,
			b.ClientID, ClientFullName, CA_STR AS ClientAdress, '''' + ClientINN AS ClientINN,
			h.CP_FIO AS ClientDir, h.CP_POS AS CLientDirPosition, h.CP_PHONE AS ClientDirPhone,
			i.CP_FIO AS ClientBuh, i.CP_POS AS ClientBuhPosition, i.CP_PHONE AS ClientBuhPhone,
			j.CP_FIO AS ClientRes, j.CP_POS AS ClientResPosition, j.CP_PHONE AS ClientResPhone,
			ISNULL(e.ClientTypeName, '') AS ClientTypeName,
			ServiceName + ' / ' + ManagerName AS ClientService,
			ClientMainBook, ClientNewspaper, ServiceStatusName,
			LEFT(REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + '(' + DistrTypeName + '), '
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = b.ClientID AND z.DS_REG = 0
					ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
				)), 1, 2, '')
			), 250) AS SystemList
		FROM
			dbo.TableIDFromXML(@LIST) a
			INNER JOIN dbo.ClientTable b ON ID = ClientID
			INNER JOIN dbo.ServiceTable c ON ServiceID = ClientServiceID
			INNER JOIN dbo.ManagerTable d ON d.ManagerID = c.ManagerID
			INNER JOIN dbo.ServiceStatusTable f ON f.ServiceStatusID = b.StatusID
			LEFT OUTER JOIN dbo.ClientTypeTable e ON e.ClientTypeID = b.ClientTypeID
			LEFT OUTER JOIN dbo.ClientAddressView g ON g.CA_ID_CLIENT = b.ClientID
			LEFT OUTER JOIN dbo.ClientPersonalDirView h WITH(NOEXPAND) ON h.CP_ID_CLIENT = b.ClientID
			LEFT OUTER JOIN dbo.ClientPersonalBuhView i WITH(NOEXPAND) ON i.CP_ID_CLIENT = b.ClientID
			LEFT OUTER JOIN dbo.ClientPersonalResView j WITH(NOEXPAND) ON j.CP_ID_CLIENT = b.ClientID

		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_LIST_EXPORT] TO rl_client_list_export;
GO
