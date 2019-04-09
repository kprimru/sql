USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeComplectClientView]
AS
	SELECT 
		ClientID, ISNULL(ClientFullName, Comment) AS ClientName, 
		ISNULL(ServiceName, SubhostName) AS ServiceName, ServiceID,
		a.HostID, a.DistrNumber, a.CompNumber, a.DistrStr, a.DS_INDEX, a.DS_REG, a.NT_SHORT, a.NT_TECH, a.SystemOrder,
		ISNULL(c.ServiceStatusIndex, a.DS_INDEX) AS ServiceStatusIndex,
		SST_SHORT, a.SystemShortName, ManagerID, ManagerName, SubhostName, Complect
	FROM
		(
			SELECT 
				c.HostID, c.DistrNumber, c.CompNumber, c.DistrStr, c.SubhostName, c.DS_INDEX, c.DS_REG, c.NT_SHORT, c.NT_TECH, c.Comment, c.SystemOrder,
				c.SST_SHORT, c.SystemShortName, c.Complect
			FROM
				(
					SELECT DISTINCT Complect, y.SystemID
					FROM 
						Reg.RegNodeSearchView z WITH(NOEXPAND)
						INNER JOIN dbo.SystemTable y ON z.Complect LIKE y.SystemBaseName + '%'
					WHERE Complect IS NOT NULL AND DS_REG <> 2
				) AS a
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.Complect = a.Complect AND c.SystemID = a.SystemID AND a.Complect LIKE '%' + CONVERT(VARCHAR(20), DistrNumber) + '%'
			WHERE DS_REG <> 2
		) AS a
		LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
		LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
