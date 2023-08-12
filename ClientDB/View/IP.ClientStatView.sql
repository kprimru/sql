﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[ClientStatView]', 'V ') IS NULL EXEC('CREATE VIEW [IP].[ClientStatView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [IP].[ClientStatView]
AS
	SELECT CSD_SYS, CSD_DISTR, CSD_COMP, CSD_ID, ISNULL(CSD_START, CSD_END) AS CSD_DATE, CSD_START_WITHOUT_MS
	FROM [IPLogs].[dbo.ClientStatDetail]
GO
