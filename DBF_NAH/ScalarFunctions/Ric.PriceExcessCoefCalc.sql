USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Ric].[PriceExcessCoefCalc]
(
	@PR_ALG	SMALLINT,
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ALG

	DECLARE @EXCESS	DECIMAL(10, 4)

	SELECT @EXCESS = Ric.PriceExcess(@PR_ALG, @PR_ID)

	IF @PR_DATE >= '20100101'
	BEGIN
		SET @RES =
			CASE
				WHEN @EXCESS < 5 THEN 1
				WHEN @EXCESS >= 5 AND @EXCESS < 10 THEN 1.05
				WHEN @EXCESS >= 10 AND @EXCESS < 20 THEN 1.10
				WHEN @EXCESS >= 20 AND @EXCESS < 30 THEN 1.20
				WHEN @EXCESS >= 30 AND @EXCESS < 50 THEN 1.30
				WHEN @EXCESS >= 50 AND @EXCESS < 70 THEN 1.50
				WHEN @EXCESS >= 70 AND @EXCESS < 90 THEN 1.70
				WHEN @EXCESS >= 90 AND @EXCESS < 110 THEN 1.90
				WHEN @EXCESS >= 110 AND @EXCESS < 130 THEN 2.10
				WHEN @EXCESS >= 130 AND @EXCESS < 150 THEN 2.30
				WHEN @EXCESS >= 150 AND @EXCESS < 170 THEN 2.50
				WHEN @EXCESS >= 170 AND @EXCESS < 190 THEN 2.70
				WHEN @EXCESS >= 190 AND @EXCESS < 210 THEN 2.90
				ELSE NULL
			END
	END

	RETURN @RES
END

GO
