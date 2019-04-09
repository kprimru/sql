USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ZVE_CLOSED]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientName AS [������], ServiceName AS [��], ManagerName AS [���-��], DistrStr AS [�����������], NT_SHORT AS [����], SST_SHORT AS [��� �������]
	FROM dbo.RegNodeComplectClientView a
	WHERE a.DS_REG = 0
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.ExpDistr b
			WHERE a.HostID = b.ID_HOST
				AND a.DistrNumber = b.DISTR
				AND a.CompNumber = b.COMP
				AND b.STATUS = 1
				AND b.UNSET_DATE IS NULL
		)
		AND SST_SHORT NOT IN ('���', '���', '���', '���', '���')
		AND NT_SHORT NOT IN ('���', '����', '���1', '���2', '���')
	ORDER BY SubhostName DESC, ManagerName, ServiceName, ClientName
END
