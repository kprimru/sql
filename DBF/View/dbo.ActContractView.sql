USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ActContractView]
AS
	SELECT
		ACT_ID,
		(
			SELECT TOP 1 CO_ID
			FROM
				dbo.ContractDistrTable INNER JOIN
				dbo.ContractTable ON CO_ID = COD_ID_CONTRACT INNER JOIN
				dbo.ActDistrTable ON AD_ID_DISTR = COD_ID_DISTR
			WHERE CO_ID_CLIENT = ACT_ID_CLIENT AND AD_ID_ACT = ACT_ID
			ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
		) AS CO_ID
	FROM dbo.ActTableGO
