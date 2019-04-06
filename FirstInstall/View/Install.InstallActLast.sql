USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE VIEW [Install].[InstallActLast]
--WITH SCHEMABINDING
AS
	SELECT 
		IA_ID_MASTER, IA_ID, IA_NAME, 
		IA_NORM, IA_DATE, IA_END
	FROM 
		Install.InstallActAll
	WHERE IA_REF IN (1, 3)