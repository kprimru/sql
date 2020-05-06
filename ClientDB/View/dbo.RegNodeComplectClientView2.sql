USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[RegNodeComplectClientView2]
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
			R.HostID, R.DistrNumber, R.CompNumber, R.DistrStr, R.SubhostName, R.DS_INDEX, R.DS_REG, R.NT_SHORT, R.NT_TECH, R.Comment, R.SystemOrder,
			R.SST_SHORT, R.SystemShortName, R.Complect
		FROM
		(
			SELECT MainHostID, MainCompNumber, MainDistrNumber
			FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
			WHERE Complect IS NOT NULL AND Service <> 2
		) AS MD
		INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON R.HostID = MD.MainHostId AND R.DistrNumber = MD.MainDistrNumber AND R.CompNumber = MD.MainCompNumber
		WHERE DS_REG <> 2
	) AS a
	LEFT JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
	LEFT JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
