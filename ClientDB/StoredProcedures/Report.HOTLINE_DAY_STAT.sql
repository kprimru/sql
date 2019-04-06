USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[HOTLINE_DAY_STAT]
	@PARAM	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CONVERT(NVARCHAR(32), DATE_S, 104) + ' (' + DATENAME(WEEKDAY, DATE_S) + ')' AS [����], 
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
				AND b.SubhostName = ''
		) AS [�����],
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
				AND b.SubhostName = '�1'
		) AS [�������|�������],
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
				AND b.SubhostName = '�1'
		) AS [�������|���������],
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
				AND b.SubhostName = '�'
		) AS [�������|�����],
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
				AND b.SubhostName = '�1'
		) AS [�������|��������],
		(
			SELECT COUNT(*)
			FROM 
				dbo.HotlineChatView a WITH(NOEXPAND)
				--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
			WHERE a.DATE_S = z.DATE_S
		) AS [�����]	
	FROM
		(
			SELECT DISTINCT DATE_S
			FROM dbo.HotlineChatView WITH(NOEXPAND)
		) AS z
	ORDER BY DATE_S DESC
END
