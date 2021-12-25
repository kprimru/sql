﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[MonthString]
(
	@MONTH	UNIQUEIDENTIFIER,
	@DELTA	INT
)
RETURNS NVARCHAR(128)
AS
BEGIN
	DECLARE @RES VARCHAR(128)
	DECLARE @PR_DATE SMALLDATETIME

	SELECT
		@RES =
			CASE DATEPART(MONTH, DATE)
				WHEN 1 THEN 'январь'
				WHEN 2 THEN 'февраль'
				WHEN 3 THEN 'март'
				WHEN 4 THEN 'апрель'
				WHEN 5 THEN 'май'
				WHEN 6 THEN 'июнь'
				WHEN 7 THEN 'июль'
				WHEN 8 THEN 'август'
				WHEN 9 THEN 'сентябрь'
				WHEN 10 THEN 'октябрь'
				WHEN 11 THEN 'ноябрь'
				WHEN 12 THEN 'декабрь'
				ELSE '-'
			END,
		@PR_DATE = DATE
	FROM Common.Month
	WHERE ID = @MONTH

	IF @DELTA > 1
	BEGIN
		WHILE @DELTA > 1
		BEGIN
			SET @DELTA = @DELTA - 1
			SET @PR_DATE = DATEADD(MONTH, 1, @PR_DATE)
		END
		SET @RES = @RES + '-' + CASE DATEPART(MONTH, @PR_DATE)
				WHEN 1 THEN 'январь'
				WHEN 2 THEN 'февраль'
				WHEN 3 THEN 'март'
				WHEN 4 THEN 'апрель'
				WHEN 5 THEN 'май'
				WHEN 6 THEN 'июнь'
				WHEN 7 THEN 'июль'
				WHEN 8 THEN 'август'
				WHEN 9 THEN 'сентябрь'
				WHEN 10 THEN 'октябрь'
				WHEN 11 THEN 'ноябрь'
				WHEN 12 THEN 'декабрь'
				ELSE '-'
			END
	END

	RETURN @RES
END
GO
