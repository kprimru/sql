USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegProtocolTextDisconnectView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegProtocolTextDisconnectView]  AS SELECT 1')
GO
ALTER VIEW [Reg].[RegProtocolTextDisconnectView]
WITH SCHEMABINDING
AS
	SELECT ID_HOST, DISTR, COMP, DATE, COUNT_BIG(*) AS CNT
	FROM Reg.ProtocolText a
	WHERE COMMENT LIKE '%Отключение%'
	GROUP BY ID_HOST, DISTR, COMP, DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegProtocolTextDisconnectView(DISTR,ID_HOST,COMP,DATE)] ON [Reg].[RegProtocolTextDisconnectView] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC, [DATE] ASC);
GO
