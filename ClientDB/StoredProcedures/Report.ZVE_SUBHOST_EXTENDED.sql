USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ZVE_SUBHOST_EXTENDED]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SH_CAPTION AS [�������], ClientName AS [������], DistrStr AS [�����������], NT_SHORT AS [����], SST_SHORT AS [��� �������],
		(
			SELECT COUNT(*)
			FROM 
				dbo.ClientDutyQuestion a
				INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber			
			WHERE a.DISTR = DistrNumber AND a.COMP = CompNumber AND c.HostID = o_O.HostID
		) AS [���-�� ��������]
	FROM
		(
			SELECT SH_CAPTION, SH_NAME, ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder
			FROM
				(
					SELECT '�����������' AS SH_CAPTION, '' AS SH_NAME
					UNION ALL
					SELECT '��������' AS CAPTION, '�1' AS SubhostName
					UNION ALL
					SELECT '�������' AS CAPTION, '�1' AS SubhostName
					UNION ALL
					SELECT '���������' AS CAPTION, '�1' AS SubhostName
					UNION ALL
					SELECT '�����' AS CAPTION, '�' AS SubhostName
				) AS SH
				CROSS APPLY
				(
					SELECT ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder
					FROM dbo.RegNodeComplectClientView
					WHERE SubhostName = SH_NAME
						AND DS_REG = 0
				) AS CLIENT
		) AS o_O
	ORDER BY SH_NAME, SystemOrder, DistrNumber, CompNumber, ClientName
END
