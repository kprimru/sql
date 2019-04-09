USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBFDistrFinancingView]
AS	
	SELECT 
		SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, DF_DISCOUNT, DF_FIXED_PRICE,
		DF_ID_PRICE, 
		(
			SELECT TOP 1 DIS_PRICE
			FROM [PC275-SQL\DELTA].DBF.dbo.DistrPriceView
			WHERE /*PR_DATE = dbo.MonthOf(GETDATE())
				AND */DIS_ID = DF_ID_DISTR
			ORDER BY PR_DATE DESC
		) AS DEPO_PRICE
	FROM 
		[PC275-SQL\DELTA].[DBF].[dbo].[SystemTable]  
		INNER JOIN [PC275-SQL\DELTA].[DBF].[dbo].[DistrTable] ON DIS_ID_SYSTEM = SYS_ID
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrFinancingTable ON DIS_ID = DF_ID_DISTR