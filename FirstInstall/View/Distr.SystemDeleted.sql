USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Distr].[SystemDeleted] 
--WITH SCHEMABINDING
AS
	SELECT 
		SYS_ID_MASTER, SYS_ID, SYS_ID_HOST, 
		SYS_NAME, SYS_SHORT, SYS_REG, SYS_ORDER, SYS_MAIN,
		SYS_DATE, SYS_END
	FROM 
		Distr.SystemAll a
	WHERE SYS_REF = 3