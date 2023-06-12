﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrsContractView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DistrsContractView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[DistrsContractView]
AS
SELECT
		COD_ID, CO_ID, DIS_ID, DIS_STR, CD_REG_DATE, DSS_NAME
	FROM
		dbo.ContractTable AS A INNER JOIN
		dbo.ContractDistrTable AS B ON A.CO_ID = B.COD_ID_CONTRACT INNER JOIN
		dbo.DistrView AS C WITH(NOEXPAND) ON B.COD_ID_DISTR = C.DIS_ID LEFT OUTER JOIN
		dbo.ClientDistrTable AS E ON E.CD_ID_DISTR = C.DIS_ID LEFT OUTER JOIN
		dbo.DistrServiceStatusTable AS F ON E.CD_ID_SERVICE = F.DSS_ID
GO
