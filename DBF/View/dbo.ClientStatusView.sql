USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientStatusView]
AS
	SELECT 
		CL_ID, CL_PSEDO, 
		(
			SELECT TOP 1 DSS_NAME
			FROM 
				dbo.ClientDistrTable INNER JOIN
				dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
			WHERE CD_ID_CLIENT = CL_ID
			ORDER BY DSS_ACT DESC, DSS_ORDER
		) AS DSS_NAME,
		(
			SELECT TOP 1 DSS_ACT
			FROM 
				dbo.ClientDistrTable INNER JOIN
				dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
			WHERE CD_ID_CLIENT = CL_ID
			ORDER BY DSS_ACT DESC, DSS_ORDER
		) AS DSS_ACT,
		(
			SELECT TOP 1 DSS_REPORT
			FROM 
				dbo.ClientDistrTable INNER JOIN
				dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
			WHERE CD_ID_CLIENT = CL_ID
			ORDER BY DSS_ACT DESC, DSS_ORDER
		) AS DSS_REPORT
	FROM dbo.ClientTable 