USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_HOTLINE_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, d.ClientFullName,
		dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS COMPLECT,
		a.FIRST_DATE, a.START, a.FINISH, a.PROFILE, a.FIO, a.EMAIL, a.PHONE, a.CHAT, a.LGN, a.RIC_PERSONAL, a.LINKS,
		DATEDIFF(SECOND, FIRST_DATE, FIRST_ANS) AS FIRST_ANS_SPEED,
		DATEDIFF(SECOND, START, FIRST_ANS) AS SESSION_SPEED
	FROM 
		dbo.HotlineChatView a WITH(NOEXPAND)
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
		INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
		INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.CLientID = c.ID_CLIENT
	WHERE a.ID = @ID	
END
