﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ContractDistrsView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ContractDistrsView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[ContractDistrsView]
AS
	SELECT DIS_ID, CO_ID, DIS_STR, DSS_NAME
	FROM
		dbo.ClientDistrView AS A INNER JOIN
        dbo.ClientTable AS B ON A.CD_ID_CLIENT = B.CL_ID INNER JOIN
        dbo.ContractTable AS C ON B.CL_ID = C.CO_ID_CLIENT
GO
