USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ARB_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ISNULL(ManagerName, SubhostName) AS 'Руководитель', ServiceName AS 'СИ', a.DistrStr AS 'Дистрибутив', ISNULL(ClientFullName, Comment) AS 'Клиент', SST_SHORT AS 'Тип'
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
		LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON ClientID = ID_CLIENT
	WHERE a.SystemShortName IN ('МБП', 'КЮ', 'БО')
		AND a.DS_REG = 0
		AND SST_SHORT NOT IN ('ДИУ')
		AND EXISTS
			(
				SELECT *
				FROM dbo.RegNodeTable z
				WHERE z.Complect = a.Complect
					AND z.Service = 0
					AND z.SystemName = 'ARB'
			)
	ORDER BY ISNULL(ManagerName, ''), 1, 2, 4
END
