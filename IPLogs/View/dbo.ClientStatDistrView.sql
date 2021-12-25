﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientStatDistrView]
WITH SCHEMABINDING
AS
	SELECT CSD_MONTH, CSD_DAY, CSD_SYS, CSD_DISTR, CSD_COMP, FL_ID_SERVER, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientStatDetail z
		INNER JOIN dbo.ClientStat y ON y.CS_ID = z.CSD_ID_CS
		INNER JOIN dbo.Files x ON FL_ID = CS_ID_FILE
	GROUP BY CSD_DAY, CSD_SYS, CSD_DISTR, CSD_COMP, FL_ID_SERVER, CSD_MONTH
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientStatDistrView(CSD_DAY,FL_ID_SERVER,CSD_COMP,CSD_DISTR,CSD_SYS)] ON [dbo].[ClientStatDistrView] ([CSD_DAY] ASC, [FL_ID_SERVER] ASC, [CSD_COMP] ASC, [CSD_DISTR] ASC, [CSD_SYS] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDistrView(CSD_DAY,FL_ID_SERVER)+(CSD_COMP,CSD_DISTR,CSD_SYS)] ON [dbo].[ClientStatDistrView] ([CSD_DAY] ASC, [FL_ID_SERVER] ASC) INCLUDE ([CSD_COMP], [CSD_DISTR], [CSD_SYS]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDistrView(CSD_MONTH,FL_ID_SERVER)+(CSD_COMP,CSD_DISTR,CSD_SYS)] ON [dbo].[ClientStatDistrView] ([CSD_MONTH] ASC, [FL_ID_SERVER] ASC) INCLUDE ([CSD_COMP], [CSD_DISTR], [CSD_SYS]);
GO
