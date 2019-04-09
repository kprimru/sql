USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LIST_EXPORT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ROW_NUMBER() OVER(ORDER BY ClientFullName) AS CL_NUM,
		b.ClientID, ClientFullName, CA_STR AS ClientAdress, '''' + ClientINN AS ClientINN, 
		h.CP_FIO AS ClientDir, h.CP_POS AS CLientDirPosition, h.CP_PHONE AS ClientDirPhone,
		i.CP_FIO AS ClientBuh, i.CP_POS AS ClientBuhPosition, i.CP_PHONE AS ClientBuhPhone,
		j.CP_FIO AS ClientRes, j.CP_POS AS ClientResPosition, j.CP_PHONE AS ClientResPhone,
		ISNULL(e.CATEGORY, '') AS ClientTypeName,
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
		LEFT OUTER JOIN dbo.ClientTypeAllView e ON e.ClientID = b.ClientID
		LEFT OUTER JOIN dbo.ClientAddressView g ON g.CA_ID_CLIENT = b.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalDirView h WITH(NOEXPAND) ON h.CP_ID_CLIENT = b.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalBuhView i WITH(NOEXPAND) ON i.CP_ID_CLIENT = b.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalResView j WITH(NOEXPAND) ON j.CP_ID_CLIENT = b.ClientID
		
	ORDER BY ClientFullName
END