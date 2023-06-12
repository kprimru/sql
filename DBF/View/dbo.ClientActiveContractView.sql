﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientActiveContractView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientActiveContractView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[ClientActiveContractView]
AS
	SELECT CO_ID_CLIENT, CO_ID, CO_NUM, CO_DATE
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ContractTable ON CO_ID_CLIENT = CL_ID
	WHERE CO_ACTIVE = 1 --AND CL_ID = 3759

	UNION ALL


	SELECT CO_ID_CLIENT, CO_ID, CO_NUM, CO_DATE
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ContractTable ON CO_ID_CLIENT = CL_ID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ContractTable
			WHERE CO_ID_CLIENT = CL_ID
				AND CO_ACTIVE = 1
		) --AND CL_ID = 3759
GO
