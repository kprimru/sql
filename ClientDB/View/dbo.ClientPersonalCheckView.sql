USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientPersonalCheckView]
AS
	SELECT DISTINCT
		ClientID, CLientFullName, ManagerName, ServiceName, CPT_NAME, CP_PHONE,
		CASE 
			WHEN LEN(PHN) <> 11 THEN 'В номере телефона не 11 символов'
			WHEN LEFT(PHN, 1) <> 8 THEN 'Первый символ - не 8'
		END AS ERR
	FROM 
		dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
		INNER JOIN dbo.ClientPersonalType c ON c.CPT_ID = b.CP_ID_TYPE
		CROSS APPLY
			(
				SELECT ITEM AS PHN
				FROM dbo.GET_STRING_TABLE_FROM_LIST(dbo.PhoneString(CP_PHONE), ',')
			) d 
	WHERE 
			(
				LEN(PHN) <> 11
				OR
				LEFT(PHN, 1) <> 8
			)
		
	UNION
	
	SELECT DISTINCT
		ClientID, CLientFullName, ManagerName, ServiceName, CPT_NAME, CP_PHONE,
		'Не указана должность сотрудника'
	FROM 
		dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
		INNER JOIN dbo.ClientPersonalType c ON c.CPT_ID = b.CP_ID_TYPE
	WHERE (CP_POS = '' OR CP_POS = '-')
