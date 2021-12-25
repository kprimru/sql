﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegProtocolTextConnectView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegProtocolTextConnectView]  AS SELECT 1')
GO
ALTER VIEW [Reg].[RegProtocolTextConnectView]
WITH SCHEMABINDING
AS
	SELECT ID_HOST, DISTR, COMP, DATE, COUNT_BIG(*) AS CNT
	FROM Reg.ProtocolText a
	WHERE COMMENT LIKE '%включение%' OR COMMENT LIKE '%новая%'
	GROUP BY ID_HOST, DISTR, COMP, DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegProtocolTextConnectView(DISTR,ID_HOST,COMP,DATE)] ON [Reg].[RegProtocolTextConnectView] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC, [DATE] ASC);
GO
