USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Clients].[ClientActive]
--WITH SCHEMABINDING
AS
	SELECT
		CL_ID_MASTER, CL_ID, CL_NAME, CL_DATE, CL_END
	FROM
		Clients.ClientAll
	WHERE CL_REF = 1