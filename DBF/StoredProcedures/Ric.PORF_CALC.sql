USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Ric].[PORF_CALC]
	@PR_ALG	SMALLINT,
	@START	DECIMAL(10, 4),
	@END	DECIMAL(10, 4),
	@WEIGHT	DECIMAL(10, 4)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ALG

	DECLARE @RES	DECIMAL(10, 4)

	IF @PR_DATE >= '20120601'
	BEGIN
		SET @RES = ROUND(100 * (@END - @START + @WEIGHT) / @START, 2)
	END

	SELECT @RES AS PORF
END
