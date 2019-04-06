USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Clients].[ClientAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		CL_ID_MASTER, CL_ID, CL_NAME, CL_DATE, CL_END, CL_REF
	FROM 
		Clients.ClientDetail