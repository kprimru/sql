USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[HOTLINE_ALIEN]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SubhostName, Comment, DistrStr, FIRST_DATE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL
	FROM 
		dbo.HotlineChat a
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber AND SystemRic = 20
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON b.HostID = c.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
	WHERE RIC_PERSONAL <> ''
		AND CHAT LIKE '%] ��� (%'
		AND
		(
			c.SubhostName = '�1' AND RIC_PERSONAL NOT LIKE '%�������%'
			OR
			c.SubhostName = '�1' AND RIC_PERSONAL NOT LIKE '%���������%'
			OR
			--c.SubhostName = '�1' AND RIC_PERSONAL NOT LIKE '%��������%'
			--OR
			c.SubhostName = '�' AND RIC_PERSONAL NOT LIKE '%�����%'	
		)
	ORDER BY FIRST_DATE DESC
END
