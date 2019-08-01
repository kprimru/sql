USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[STT_SEND]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ISNULL(ClientFullName, d.Comment) AS [������], ISNULL(ManagerName, SubhostName) AS [���-��], ServiceName AS [��], 
		ISNULL(b.DistrStr, d.DistrStr) AS [���.�����������], dbo.DateOf(CSD_DATE) AS [��������� �������� STT],
		Common.DateDiffString(CSD_DATE, GETDATE()) AS [��� �����]	
	FROM
		(
			SELECT HostID, CSD_DISTR, CSD_COMP, MAX(ISNULL(CSD_START, CSD_END)) AS CSD_DATE
			FROM 
				dbo.IPSttView
				INNER JOIN dbo.SystemTable ON CSD_SYS = SystemNumber
			--WHERE CSD_STT_SEND = 1 AND CSD_STT_RESULT = 1
			GROUP BY HostID, CSD_DISTR, CSD_COMP
		) AS a
		LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
		LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		LEFT OUTER JOIN Reg.RegNodeSearchView d WITH(NOEXPAND) ON a.HostID = d.HostID AND a.CSD_DISTR = d.DistrNumber AND a.CSD_COMP = d.CompNumber
	WHERE d.DS_REG = 0
	ORDER BY ISNULL(ManagerName, ''), 2, 3, 1, 4
END
