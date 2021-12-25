﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Функция, возвращающая задел
*/
ALTER FUNCTION [Ric].[StockValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES	DECIMAL(10, 4)

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ID

	IF @PR_DATE BETWEEN '20111201' AND '20120901'
		SET @RES = dbo.CrisisCoef(dbo.PERIOD_DELTA(@PR_ID, -12))
	ELSE IF @PR_DATE BETWEEN '20121201' AND '20130901'
		SET @RES = dbo.CrisisCoef(dbo.PERIOD_DELTA(@PR_ID, -24)) / 3 + 2 * dbo.KBUValue(dbo.PERIOD_DELTA(@PR_ID, -12)) / 3
	ELSE IF @PR_DATE >= '20131201'
		SET @RES = dbo.KBUValue(dbo.PERIOD_DELTA(@PR_ID, -24)) / 3 + 2 * dbo.KBUValue(dbo.PERIOD_DELTA(@PR_ID, -12)) / 3
	ELSE
		SET @RES = NULL

	RETURN @RES
END

GO
