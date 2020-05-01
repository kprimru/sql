USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[IncomeView]
AS
	SELECT     
		IN_ID, IN_ID_CLIENT, IN_PRIMARY, IN_DATE, IN_SUM, IN_PAY_DATE, 
		IN_PAY_NUM, 
		IN_SUM - 
			ISNULL(
				(
					SELECT SUM(ID_PRICE)
					FROM         
						dbo.IncomeDistrTable
					WHERE ID_ID_INCOME = IN_ID
				), 0) AS IN_REST, IN_ID_INVOICE, ORG_ID, ORG_PSEDO
	FROM
		dbo.IncomeTable LEFT OUTER JOIN
		dbo.OrganizationTable ON ORG_ID = IN_ID_ORG
