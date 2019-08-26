USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BL_GET_CLIENT_SYSTEMS_ALL]
     @clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		f.ID, 
		SystemShortName, a.SystemID, a.SystemBaseName,
        DISTR AS SystemDistrNumber, COMP AS CompNumber,
		SystemTypeName,	
        DistrTypeName, 
		DS_NAME AS ServiceStatusName,
        f.Complect
	FROM
		dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN dbo.RegNodeTable f ON	f.SystemName = a.SystemBaseName 
										AND f.DistrNumber = a.DISTR
										AND f.CompNumber = a.COMP
	WHERE  ID_CLIENT = @clientid
	ORDER BY DS_INDEX, SystemOrder
END
