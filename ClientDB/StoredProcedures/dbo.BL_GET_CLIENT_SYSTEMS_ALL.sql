USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Выборка всех систем клиента

CREATE PROCEDURE [dbo].[BL_GET_CLIENT_SYSTEMS_ALL]
     @clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		f.ID, 
		SystemShortName, a.ID_SYSTEM AS SystemID, b.SystemBaseName,
        DISTR AS SystemDistrNumber, COMP AS CompNumber,
		SystemTypeName,	
        DistrTypeName, 
		DS_NAME AS ServiceStatusName,
        f.Complect
	FROM
		dbo.ClientDistr a INNER JOIN	
		dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID INNER JOIN
		dbo.SystemTypeTable c ON c.SystemTypeID = a.ID_TYPE INNER JOIN
		dbo.DistrTypeTable d ON d.DistrTypeID = a.ID_NET INNER JOIN
		--ServiceStatusTable e ON e.ServiceStatusID = a.SystemStatusID LEFT OUTER JOIN
		dbo.DistrStatus ON DS_ID = ID_STATUS LEFT OUTER JOIN
		dbo.RegNodeTable f ON f.SystemName = b.SystemBaseName 
						AND f.DistrNumber = a.DISTR
						AND f.CompNumber = a.COMP
	WHERE  ID_CLIENT = @clientid AND a.STATUS = 1
	ORDER BY DS_INDEX, SystemOrder
END