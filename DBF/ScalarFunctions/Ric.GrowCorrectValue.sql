USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Ric].[GrowCorrectValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	DECLARE @GROWF	DECIMAL(10, 4)

	SET @GROWF = Ric.GrowFactValue(@PR_ID)

	IF @GROWF >= 0
		SET @RES = @GROWF * Ric.SmallnessCoef(@PR_ID) * Ric.DepthCoef(@PR_ID)
	ELSE
		SET @RES = @GROWF / Ric.DepthCoef(@PR_ID)

	RETURN @RES
END
GO
