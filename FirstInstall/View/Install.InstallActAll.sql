USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Install].[InstallActAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		IA_ID_MASTER, IA_ID, IA_NAME, 
		IA_NORM, IA_DATE, IA_END, IA_REF
	FROM 
		Install.InstallActDetail