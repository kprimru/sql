USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EXPERT_QUESTION_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, c.Comment/*ISNULL(e.ClientFullName, c.Comment)*/ AS CLIENT, ISNULL(e.ManagerName, c.SubhostName) AS MANAGER, 
		DATE, FIO, EMAIL, PHONE, QUEST, 
		(SELECT TOP 1 ID FROM dbo.CallDirection WHERE NAME = '��������������') AS DIRECTION
	FROM 
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON a.DISTR = d.DISTR AND a.COMP = d.COMP AND b.HostID = d.HostID
		LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
	ORDER BY DATE DESC	
END
