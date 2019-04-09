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

	SELECT o_O.ClientID, ClientFullName, ServiceName, ManagerName, LAST_DATE, ContractTypeName, t.CATEGORY
	FROM
		(
			SELECT 
				b.ClientID, b.ClientFullName, b.ServiceName, b.ManagerName, b.ManagerLogin,
				d.ContractTypeName,
				dbo.Dateof((
					SELECT MAX(DATE)
					FROM dbo.ClientContact
					WHERE STATUS = 1
						AND ID_CLIENT = b.ClientID
				)) AS LAST_DATE
			FROM 
				dbo.ClientWriteList() a
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON WCL_ID = ClientID
				INNER JOIN dbo.ClientTable c ON c.ClientID = b.ClientID
				INNER JOIN dbo.ContractTypeTable d ON d.ContractTypeID = c.ClientContractTypeID
			WHERE ServiceStatusID = 2
				AND ManagerName NOT IN ('Тихомирова', 'Батенева', 'Чичиланова')
				AND d.ContractTypeName IN ('коммерческий', 'коммерческий VIP', 'пакетное соглашение', 'рамочное соглашение', 'спецовый')
		) AS o_O
	LEFT JOIN dbo.ClientTypeAllView T ON t.ClientID = o_O.ClientId
	WHERE (LAST_DATE IS NULL OR DATEDIFF(DAY, LAST_DATE, GETDATE()) > 180)
	ORDER BY ISNULL(LAST_DATE, GETDATE()) DESC, LAST_DATE DESC, ManagerName, ServiceName
END
