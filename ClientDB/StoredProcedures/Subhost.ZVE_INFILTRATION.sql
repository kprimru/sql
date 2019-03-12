USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[ZVE_INFILTRATION]
	@SUBHOST	NVARCHAR(16),
	@EMPTY		BIT
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientName, DistrStr, NT_SHORT, SST_SHORT,
		CNT
	FROM
		(
			SELECT SH_CAPTION, SH_NAME, ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ClientDutyQuestion a
						INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber			
					WHERE a.DISTR = DistrNumber AND a.COMP = CompNumber AND c.HostID = CLIENT.HostID
				) AS CNT
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
	WHERE SH_NAME = @SUBHOST
		AND 
			(
				@EMPTY = 0 
				OR
				@EMPTY = 1 AND CNT = 0					
			)
	ORDER BY SystemOrder, DistrNumber, CompNumber, ClientName
END
