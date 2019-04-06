USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_HOTLINE_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	-- отдельно для Славянки
	IF @CLIENT = 3103
		SELECT 
			a.ID,
			dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS COMPLECT,
			a.FIRST_DATE, a.START, a.FINISH, a.PROFILE, a.FIO, a.EMAIL, a.PHONE, a.CHAT, a.LGN, a.RIC_PERSONAL, a.LINKS,
			(SELECT TOP 1 ID FROM dbo.CallDirection WHERE NAME = 'ЧАТ') AS DIRECTION
		FROM 
			dbo.HotlineChat a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
		WHERE c.SubhostName = 'Л1'
		ORDER BY FIRST_DATE DESC
	ELSE
		SELECT 
			a.ID,
			dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS COMPLECT,
			a.FIRST_DATE, a.START, a.FINISH, a.PROFILE, a.FIO, a.EMAIL, a.PHONE, a.CHAT, a.LGN, a.RIC_PERSONAL, a.LINKS,
			(SELECT TOP 1 ID FROM dbo.CallDirection WHERE NAME = 'ЧАТ') AS DIRECTION
		FROM 
			dbo.HotlineChat a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
			INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
		WHERE c.ID_CLIENT = @CLIENT
		ORDER BY FIRST_DATE DESC
END
