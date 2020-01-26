USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTACT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT o_O.ClientID, ClientFullName, ServiceName, ManagerName, LAST_DATE, ContractTypeName, CATEGORY = ClientTypeName
	FROM
		(
			SELECT 
				b.ClientID, b.ClientFullName, b.ServiceName, b.ManagerName, b.ManagerLogin,
				ContractTypeName = d.Name, t.ClientTypeName,
				dbo.Dateof((
					SELECT TOP (1) DATE
					FROM dbo.ClientContact cc
						INNER JOIN dbo.ClientContactType cct ON cc.ID_TYPE = cct.ID
					WHERE STATUS = 1
						AND ID_CLIENT = b.ClientID
						AND (cct.NAME='Визит плановый' OR cct.NAME='Визит срочный')
					ORDER BY DATE DESC
				)) AS LAST_DATE
			FROM 
				dbo.ClientWriteList() a
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON WCL_ID = ClientID
				INNER JOIN dbo.ClientTable c ON c.ClientID = b.ClientID
				INNER JOIN dbo.ClientTypeTable t ON c.ClientTypeId = t.ClientTypeId
				INNER JOIN dbo.ClientKind d ON d.Id = c.ClientKind_Id
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId
			WHERE	ManagerName NOT IN ('Тихомирова', 'Батенева', 'Чичиланова')
				AND d.Name IN ('коммерческий', 'коммерческий ВИП', 'спецовый', 'пакетное соглашение')
		) AS o_O
	WHERE (LAST_DATE IS NULL OR DATEDIFF(DAY, LAST_DATE, GETDATE()) > 180)
	ORDER BY ISNULL(LAST_DATE, GETDATE()) DESC, LAST_DATE DESC, ManagerName, ServiceName
END
