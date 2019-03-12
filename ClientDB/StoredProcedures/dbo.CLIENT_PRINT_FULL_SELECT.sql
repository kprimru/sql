USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_PRINT_FULL_SELECT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CLIENT	TABLE(CL_ID INT PRIMARY KEY)	

	INSERT INTO @CLIENT
		SELECT ID
		FROM dbo.TableIDFromXML(@LIST)

	SELECT 
		a.ClientID, ClientFullName, ServiceName, CA_STR_PRNT AS ClientAdress, ClientINN, 
		g.CP_FIO AS ClientDir, g.CP_POS AS ClientDirPosition, g.CP_PHONE AS ClientDirPhone, 
		h.CP_FIO AS ClientBuh, h.CP_POS AS ClientBuhPosition, h.CP_PHONE AS ClientBuhPhone,
		i.CP_FIO AS ClientRes, i.CP_POS AS ClientResPosition, i.CP_PHONE AS ClientResPhone,
		ServiceTypeName, 

		ContractNumber, ContractTypeName, ContractBeginStr,
		ContractConditions, ContractPayName, ContractYear,

		ClientActivity, ClientDayBegin, ClientDayEnd, 
		ClientNewsPaper, ClientMainBook, PayTypeName, 
		DayName, ServiceStart, ServiceTime,
		ClientNote, ClientEmail, ClientPlace,
	
		NULL AS SystemShortName, NULL AS DistrStr, NULL AS DistrTypeName, 
		NULL AS SystemTypeName, NULL AS ServiceStatusName,
		NULL AS ServiceStatusIndex, NULL AS SystemOrder, NULL AS SystemDistrNumber
	FROM 
		@CLIENT
		INNER JOIN dbo.ClientTable a ON CL_ID = a.ClientID
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ServiceTypeTable c ON a.ServiceTypeID = c.ServiceTypeID
		LEFT OUTER JOIN dbo.ClientAddressView f ON f.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
		LEFT OUTER JOIN dbo.ClientPersonalDirView g WITH(NOEXPAND) ON g.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalBuhView h WITH(NOEXPAND) ON h.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalResView i WITH(NOEXPAND) ON i.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.PayTypeTable d ON a.PayTypeID = d.PayTypeID
		LEFT OUTER JOIN dbo.DayTable e ON e.DayID = a.DayID
		LEFT OUTER JOIN
			(
				SELECT 
					ClientID, ContractNumber, ContractTypeName, ContractBegin AS 
ContractBeginStr,
					ContractConditions, ContractPayName, ContractYear,
					ROW_NUMBER() OVER(PARTITION BY CLientID ORDER BY ContractBegin 
DESC) AS RN
				FROM 
					dbo.ContractTable z
					INNER JOIN dbo.ContractTypeTable y ON y.ContractTypeID = 
z.ContractTypeID
					INNER JOIN dbo.ContractPayTable x ON x.ContractPayID = 
z.ContractPayID
			) AS t ON t.ClientID = a.ClientID AND RN = 1
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrView z WITH(NOEXPAND)
			WHERE z.ID_CLIENT = a.ClientID
		)

	UNION ALL

	SELECT 
		a.ClientID, ClientFullName, ServiceName, CA_STR_PRNT AS ClientAdress, ClientINN, 
		g.CP_FIO AS ClientDir, g.CP_POS AS ClientDirPosition, g.CP_PHONE AS ClientDirPhone, 
		h.CP_FIO AS ClientBuh, h.CP_POS AS ClientBuhPosition, h.CP_PHONE AS ClientBuhPhone,
		i.CP_FIO AS ClientRes, i.CP_POS AS ClientResPosition, i.CP_PHONE AS ClientResPhone,
		ServiceTypeName, 

		ContractNumber, ContractTypeName, ContractBeginStr,
		ContractConditions, ContractPayName, ContractYear,

		ClientActivity, ClientDayBegin, ClientDayEnd, 
		ClientNewsPaper, ClientMainBook, PayTypeName, 
		DayName, ServiceStart, ServiceTime,
		ClientNote, ClientEmail, ClientPlace,
	
		SystemShortName, DistrStr, DistrTypeName, 
		SystemTypeName, ServiceStatusName,
		ServiceStatusIndex, SystemOrder, SystemDistrNumber
	FROM 
		@CLIENT
		INNER JOIN dbo.ClientTable a ON CL_ID = a.ClientID
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ServiceTypeTable c ON a.ServiceTypeID = c.ServiceTypeID
		INNER JOIN
			(
				SELECT 
					ID_CLIENT AS ClientID, SystemShortName, 
					CONVERT(VARCHAR(20), DISTR) +
					CASE COMP
						WHEN 1 THEN ''
						ELSE '/' + CONVERT(VARCHAR(20), COMP)
					END AS DistrStr, DistrTypeName, SystemTypeName, DS_NAME AS 
ServiceStatusName,
					DS_INDEX AS ServiceStatusIndex, SystemOrder, DISTR AS 
SystemDistrNumber
				FROM dbo.ClientDistrView WITH(NOEXPAND)
			) AS o_O ON o_O.ClientID = a.ClientID
		LEFT OUTER JOIN dbo.ClientAddressView f ON f.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
		LEFT OUTER JOIN dbo.ClientPersonalDirView g WITH(NOEXPAND) ON g.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalBuhView h WITH(NOEXPAND) ON h.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalResView i WITH(NOEXPAND) ON i.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.PayTypeTable d ON a.PayTypeID = d.PayTypeID
		LEFT OUTER JOIN dbo.DayTable e ON e.DayID = a.DayID
		LEFT OUTER JOIN
			(
				SELECT 
					ClientID, ContractNumber, ContractTypeName, ContractBegin AS 
ContractBeginStr,
					ContractConditions, ContractPayName, ContractYear,
					ROW_NUMBER() OVER(PARTITION BY CLientID ORDER BY ContractBegin 
DESC) AS RN
				FROM 
					dbo.ContractTable z
					INNER JOIN dbo.ContractTypeTable y ON y.ContractTypeID = 
z.ContractTypeID
					INNER JOIN dbo.ContractPayTable x ON x.ContractPayID = 
z.ContractPayID
			) AS t ON t.ClientID = a.ClientID AND RN = 1

	ORDER BY ClientFullName, ClientID, ServiceStatusIndex, SystemOrder, SystemDistrNumber
END