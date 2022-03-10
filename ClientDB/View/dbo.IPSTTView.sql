﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IPSTTView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[IPSTTView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[IPSTTView]
AS
	SELECT CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_END
	FROM IP.ClientStatSTTCache
	/*
	FROM IPLogs.dbo.ClientStatDetail
	WHERE CSD_STT_SEND = 1 AND CSD_STT_RESULT = 1
	*/
GO
