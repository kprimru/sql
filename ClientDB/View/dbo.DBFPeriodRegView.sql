USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DBFPeriodRegView]
AS
	SELECT PR_DATE, SYS_REG_NAME, REG_DISTR_NUM, REG_COMP_NUM, SST_NAME, DS_REG, SNC_NET_COUNT, SNC_TECH
	FROM
		[PC275-SQL\DELTA].DBF.dbo.PeriodRegView
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemTable ON REG_ID_SYSTEM = SYS_ID
