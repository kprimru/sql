USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[IPClientDetailView]
AS
	SELECT CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_CODE_CLIENT, CSD_USR
	FROM [IPLogs].[dbo.ClientStatDetail]
GO
