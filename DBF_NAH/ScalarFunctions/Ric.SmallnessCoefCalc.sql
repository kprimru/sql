﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[SmallnessCoefCalc]', 'FN') IS NULL EXEC('CREATE FUNCTION [Ric].[SmallnessCoefCalc] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Ric].[SmallnessCoefCalc]
(
	@COEF	DECIMAL(10, 4),
	@QR_ID	SMALLINT,
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	DECLARE @VKSP	DECIMAL(10, 4)
	DECLARE @WS		DECIMAL(10, 4)

	SELECT @VKSP = Ric.VKSPGet(dbo.QuarterPeriod(dbo.QuarterDelta(@QR_ID, -2), 3), @PR_ID)

	SELECT @WS = @COEF

	IF @VKSP / @WS <= 0.5
		SET @RES = 0.5
	ELSE IF ((@VKSP / @WS) < 1) AND ((@VKSP / @WS) > 0.5)
		SET @RES = @VKSP / @WS
	ELSE IF @VKSP / @WS >= 1
		SET @RES = 1
	ELSE
		SET @RES = NULL

	SET @RES = ROUND(@RES, 2)

	RETURN @RES
END
GO
