﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ClientStatDistrView]
AS
	SELECT CSD_MONTH, CSD_DAY, CSD_SYS, CSD_DISTR, CSD_COMP, FL_ID_SERVER, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientStatDetail z
		INNER JOIN dbo.ClientStat y ON y.CS_ID = z.CSD_ID_CS
		INNER JOIN dbo.Files x ON FL_ID = CS_ID_FILE
	GROUP BY CSD_DAY, CSD_SYS, CSD_DISTR, CSD_COMP, FL_ID_SERVER, CSD_MONTH
GO
