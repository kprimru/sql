USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientIndexView]
AS
	SELECT 
		a.ClientID,
		CONVERT(VARCHAR(20), ClientID) + ' ' +
		ClientFullName + ' ' + 
		ClientShortName + ' ' +
		ISNULL(ClientOfficial, '') + ' ' + 
		ISNULL(
			(
				SELECT NAME + ','
				FROM dbo.ClientNames
				WHERE ID_CLIENT = a.ClientID
				FOR XML PATH('')
			)
			, '') + ' ' +
		ServiceName + ' ' +
		ManagerName + ' ' +
		ISNULL(REVERSE(STUFF(REVERSE((
			SELECT DistrStr + ' ' + DistrTypeName + ', '
			FROM dbo.ClientDistrView b WITH(NOEXPAND)
			WHERE a.ClientID = b.ID_CLIENT
			/*ORDER BY SystemOrder */FOR XML PATH('')
		)), 1, 2, '')), '') + ' ' +
		ISNULL(REVERSE(STUFF(REVERSE((
			SELECT EMAIL + ', '
			FROM dbo.ClientDelivery b
			WHERE a.ClientID = b.ID_CLIENT
			/*ORDER BY SystemOrder */FOR XML PATH('')
		)), 1, 2, '')), '') + ' ' +
		ISNULL(ContractTypeName, '') + ' ' +
		ISNULL(ServiceTypeName, '') + ' ' +
		ISNULL(ServiceTypeShortName, '') + ' ' + 
		ISNULL(ClientActivity, '') + ' ' +
		ClientINN + ' ' +
		ISNULL(REVERSE(STUFF(REVERSE((
			SELECT CA_STR + ', '
			FROM dbo.ClientAddressView b
			WHERE a.ClientID = b.CA_ID_CLIENT
			/*ORDER BY SystemOrder */FOR XML PATH('')
		)), 1, 2, '')), '') + ' ' +
		ISNULL(REVERSE(STUFF(REVERSE((
			SELECT 
				ISNULL(g.CP_SURNAME, '') + ' ' +
				ISNULL(g.CP_NAME, '') + ' ' +
				ISNULL(g.CP_PATRON, '') + ' ' +
				ISNULL(g.CP_POS, '') + ' ' +
				ISNULL(g.CP_PHONE, '') + ' ' +
				ISNULL(g.CP_PHONE_S, '') + ' ' + 
				ISNULL(g.CP_NOTE, '') + ' '	+		
				ISNULL(g.CP_EMAIL, '') + ' '
			FROM dbo.ClientPersonal g 
			WHERE a.ClientID = g.CP_ID_CLIENT
			/*ORDER BY SystemOrder */FOR XML PATH('')
		)), 1, 2, '')), '') + '' +
		ISNULL(REVERSE(STUFF(REVERSE((
			SELECT 
				ISNULL(i.SURNAME, '') + ' ' +
				ISNULL(i.NAME, '') + '' +
				ISNULL(i.PATRON, '') + ' ' +
				ISNULL(i.POS, '') + ' ' +
				ISNULL(i.PHONE, '') + ' '	
			FROM dbo.ClientPersonalOtherView i
			WHERE a.ClientID = i.ClientID
			/*ORDER BY SystemOrder */FOR XML PATH('')
		)), 1, 2, '')), '') AS ClientData
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ServiceTable c ON c.ServiceID = a.ClientServiceID
		INNER JOIN dbo.ManagerTable d ON d.ManagerID = c.ManagerID
		INNER JOIN dbo.ServiceTypeTable f ON f.ServiceTypeID = a.ServiceTypeID
		LEFT OUTER JOIN dbo.ContractTypeTable e ON e.ContractTypeID = a.ClientContractTypeID