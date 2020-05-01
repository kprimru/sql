USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ClientContractDistrView]
AS
	SELECT
		dbo.ClientTable.CL_ID, dbo.ClientTable.CL_PSEDO, dbo.ClientTable.CL_FULL_NAME, dbo.ContractTypeTable.CTT_NAME,
                      dbo.ContractTypeTable.CTT_ID, dbo.ContractTable.CO_ID, dbo.ContractTable.CO_NUM, dbo.ContractTable.CO_DATE, dbo.ContractTable.CO_BEG_DATE,
                       dbo.DistrView.DIS_STR, dbo.DistrView.DIS_NUM
FROM         dbo.ClientTable INNER JOIN
                      dbo.ContractTable ON dbo.ClientTable.CL_ID = dbo.ContractTable.CO_ID_CLIENT INNER JOIN
                      dbo.ContractDistrTable ON dbo.ContractTable.CO_ID = dbo.ContractDistrTable.COD_ID_CONTRACT INNER JOIN
                      dbo.DistrView WITH(NOEXPAND) ON dbo.DistrView.DIS_ID = dbo.ContractDistrTable.COD_ID_DISTR LEFT OUTER JOIN
                      dbo.ContractTypeTable ON dbo.ContractTable.CO_ID_TYPE = dbo.ContractTypeTable.CTT_ID
