﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DBFBillView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DBFBillView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[DBFBillView]
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE
	FROM dbo.DBFBill
GO
