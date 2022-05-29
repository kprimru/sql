﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DBFDistrView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DBFDistrView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[DBFDistrView]
AS
	SELECT
		SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM,
		DF_FIXED_PRICE, DF_DISCOUNT, DSS_REPORT,
		DF_ID_PRICE,
		(
			SELECT TOP 1 DIS_PRICE
			FROM [DBF].[dbo.DistrPriceView]
			WHERE PR_DATE <= GETDATE()
				AND DIS_ID = DF_ID_DISTR
			ORDER BY PR_DATE DESC
		) AS DEPO_PRICE
	FROM [DBF].[dbo.SystemTable]
	INNER JOIN [DBF].[dbo.DistrTable] ON DIS_ID_SYSTEM = SYS_ID
	INNER JOIN [DBF].[dbo.DistrFinancingTable] ON DIS_ID = DF_ID_DISTR
	INNER JOIN [DBF].[dbo.ClientDistrTable] ON DIS_ID = CD_ID_DISTR
	INNER JOIN [DBF].[dbo.DistrServiceStatusTable] ON CD_ID_SERVICE = DSS_ID
GO
