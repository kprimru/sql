USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_CALC_CHECK]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_ID, Subhost.MinPrice(@SH_ID) AS MIN_PRICE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ID
		AND PR_DATE >= '20111101'
END
