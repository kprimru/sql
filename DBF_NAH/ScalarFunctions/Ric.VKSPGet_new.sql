USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Ric].[VKSPGet_New]
(
	@PR_DATE			SMALLDATETIME
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES	DECIMAL(10, 4)

	DECLARE @PR_ID SMALLINT
	SELECT @PR_ID = PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE = @PR_DATE

	SELECT @RES = SUM(WEIGHT)
	FROM dbo.PeriodRegExceptView a
	INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
	INNER JOIN dbo.WeightRules ON REG_ID_NET = ID_NET
								AND REG_ID_SYSTEM = ID_SYSTEM
								AND REG_ID_TYPE = ID_TYPE
								AND REG_ID_PERIOD = ID_PERIOD
	WHERE DS_REG = 0 AND REG_ID_PERIOD = @PR_ID

	RETURN @RES
END

GO