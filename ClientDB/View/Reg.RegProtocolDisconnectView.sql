USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegProtocolDisconnectView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegProtocolDisconnectView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [Reg].[RegProtocolDisconnectView]
WITH SCHEMABINDING
AS
	SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE) AS DATE, COUNT_BIG(*) AS CNT
	FROM dbo.RegProtocol a
	WHERE RPR_OPER IN ('Отключение', 'Сопровождение отключено')
	GROUP BY RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegProtocolDisconnectView(RPR_DISTR,RPR_ID_HOST,RPR_COMP,DATE)] ON [Reg].[RegProtocolDisconnectView] ([RPR_DISTR] ASC, [RPR_ID_HOST] ASC, [RPR_COMP] ASC, [DATE] ASC);
GO
