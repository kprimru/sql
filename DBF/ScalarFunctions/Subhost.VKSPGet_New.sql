USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Subhost].[VKSPGet_New]
(
	@SH_ID			SMALLINT,
	@PR_ALG			SMALLINT,
	@PR_ID			SMALLINT,
	@PR_WEIGHT		SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES	DECIMAL(10, 4)

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ALG

	IF @PR_DATE >= '20160101'
	BEGIN
		SELECT @RES = SUM(WEIGHT)
		FROM dbo.PeriodRegExceptView a
		INNER JOIN dbo.DistrStatusTable ON REG_ID_STATUS = DS_ID
		INNER JOIN dbo.WeightRules b ON REG_ID_SYSTEM = ID_SYSTEM
									AND REG_ID_NET = ID_NET
									AND REG_ID_TYPE = ID_TYPE
		WHERE REG_ID_PERIOD = @PR_ID
			AND ID_PERIOD = @PR_WEIGHT
			AND DS_REG = 0
			AND a.REG_ID_HOST = @SH_ID
	END

	RETURN @RES
END
GO
