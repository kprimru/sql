USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[EXPERT_QUESTION_LIST]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.DATE AS [Дата], ISNULL(e.ClientFullName, c.Comment) AS [Клиент], c.DistrStr AS [Дистрибутив], 
		ISNULL(e.ManagerName, c.SubhostName) AS [РГ], e.ServiceName AS [СИ], a.FIO AS [ФИО], 
		a.QUEST AS [Вопрос], a.EMAIL, a.PHONE AS [Телефон]
	FROM 
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON a.DISTR = d.DISTR AND a.COMP = d.COMP AND b.HostID = d.HostID
		LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
	ORDER BY a.DATE DESC	
END
