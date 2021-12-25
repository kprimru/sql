﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[TaxDefaultSelect]', 'IF') IS NULL EXEC('CREATE FUNCTION [Common].[TaxDefaultSelect] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [Common].[TaxDefaultSelect]
(
	@Date SMALLDATETIME
)
RETURNS TABLE
AS
RETURN
(
	SELECT ID, NAME, RATE, TOTAL_RATE, TAX_RATE
	FROM Common.Tax
	WHERE RATE = 18
		AND (@DATE IS NULL OR @DATE < '20190101')

	UNION ALL

	SELECT ID, NAME, RATE, TOTAL_RATE, TAX_RATE
	FROM Common.Tax
	WHERE RATE = 20
		AND (@DATE >= '20190101')
)
GO
