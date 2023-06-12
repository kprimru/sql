USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ConsignmentView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ConsignmentView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[ConsignmentView]
AS
	SELECT
		CSG_ID, CSG_ID_CLIENT, CSG_DATE, CSG_NUM, CSG_ID_INVOICE, -- PR_DATE, PR_ID,
			(
				SELECT SUM(CSD_TOTAL_PRICE)
				FROM dbo.ConsignmentDetailTable
				WHERE CSD_ID_CONS = a.CSG_ID
			) AS CSG_PRICE, ORG_ID, ORG_PSEDO
	FROM
		dbo.ConsignmentTable AS a INNER JOIN
		dbo.OrganizationTable ON ORG_ID = CSG_ID_ORG
		-- INNER JOIN dbo.PeriodTable AS b ON ACT_ID_PERIOD = PR_ID
GO
