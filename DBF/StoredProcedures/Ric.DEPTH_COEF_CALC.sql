USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Ric].[DEPTH_COEF_CALC]
	@PR_ALG	SMALLINT,	
	@DEPTH	DECIMAL(10, 4)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PR_DATE SMALLDATETIME

	SELECT @PR_DATE = PR_DATE 
	FROM dbo.PeriodTable 
	WHERE PR_ID = @PR_ALG

	DECLARE @RES	DECIMAL(10, 4)
	
	IF @PR_DATE >= '20120601'
	BEGIN
		IF @DEPTH <= 1
			SET @RES = 1
		ELSE IF (@DEPTH > 1) AND (@DEPTH <= 1.4)
			SET @RES = 1 + 0.5 * (@DEPTH - 1)
		ELSE IF (@DEPTH > 1.4) AND (@DEPTH <= 1.7)
			SET @RES = 1.2 + 1.5 * (@DEPTH - 1.4)
		ELSE IF @DEPTH > 1.7 
			SET @RES = 1.65 + 3 * (@DEPTH - 1.7)
		ELSE 
			SET @RES = NULL

		SET @RES = ROUND(@RES, 2)			
	END

	SELECT @RES AS DEPTH_COEF
END