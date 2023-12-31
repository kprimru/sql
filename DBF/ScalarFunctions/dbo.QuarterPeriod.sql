USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[QuarterPeriod]
(
	@QR_ID	SMALLINT,
	@CNT	TINYINT
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @RES SMALLINT

	DECLARE @QR_DATE	SMALLDATETIME

	SELECT @QR_DATE = QR_BEGIN FROM dbo.Quarter WHERE QR_ID = @QR_ID

	SELECT @RES = PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE = DATEADD(MONTH, @CNT - 1, @QR_DATE)

	RETURN @RES
END
GO
