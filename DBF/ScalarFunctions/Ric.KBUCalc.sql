USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Ric].[KBUCalc]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES	DECIMAL(10, 4)

	DECLARE @TLimit	DECIMAL(10, 4)
	DECLARE	@BLimit	DECIMAL(10, 4)

	DECLARE @GN	DECIMAL(10, 4)
	DECLARE @GS	DECIMAL(10, 4)
	DECLARE @STG	DECIMAL(10, 4)

	SELECT @GN = Ric.GrowNetworkAvgValue(@PR_ID), @GS = Ric.GrowStandardValue(@PR_ID), @STG = Ric.StageValue(@PR_ID)

	SELECT @BLimit = MIN(Val)
	FROM
		(
			SELECT (@GS - @STG) AS Val
			UNION ALL
			SELECT (@GN - 2) AS Val
		) AS o_O

	SELECT @TLimit = MIN(Val)
	FROM
		(
			SELECT (@GS) AS Val
			UNION ALL
			SELECT (@GN + @STG) AS Val
		) AS o_O

	DECLARE @GROW	DECIMAL(10, 4)

	SET @GROW = Ric.GrowCorrectValue(@PR_ID)

	SET @RES = NULL

	IF @GROW >= (@TLimit + 10)
		SET @RES = 0.5
	ELSE IF (@TLimit < @GROW) AND (@GROW < @TLimit + 10)
		SET @RES = 1 - 0.3/10 * (@GROW - @TLimit)
	ELSE IF (@BLimit <= @GROW) AND (@GROW <= @TLimit)
		SET @RES = 1
	ELSE IF ((@BLimit - 10) <= @GROW) AND (@GROW < @BLimit)
		SET @RES = 1.5 - 0.5 / 10 * (@GROW + 10 - @BLimit)
	ELSE IF (@GROW < @BLimit - 10)
		SET @RES = 1.5 - 0.5 / 13.1 * (@GROW + 10 - @BLimit)

	RETURN @RES
END
GO
