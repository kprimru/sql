USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[TOStatusView]
AS
	SELECT
		TO_ID, TO_NUM, TO_NAME, TO_ID_CLIENT, TO_ID_COUR,
		(
			SELECT TOP 1 DSS_ID
			FROM
				dbo.ClientDistrTable INNER JOIN
				dbo.TODistrTable ON TD_ID_DISTR = CD_ID_DISTR INNER JOIN
				dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
			WHERE TD_ID_TO = TO_ID
			ORDER BY DSS_ACT DESC, DSS_ORDER
		) AS DSS_ID
	FROM dbo.TOTable
GO