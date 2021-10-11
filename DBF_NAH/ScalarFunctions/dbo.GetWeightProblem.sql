USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GetWeightProblem]
(
	@SYS_ID INT,
	@NT_ID	VARCHAR(50),
	@PR_DATE SMALLDATETIME,
	@PROBLEM	BIT
)
RETURNS DECIMAL(8, 4)
AS
BEGIN

	DECLARE @result DECIMAL(8, 4)

	SELECT @result = SW_WEIGHT
	FROM
		dbo.SystemWeightTable
		INNER JOIN dbo.PeriodTable ON PR_ID = SW_ID_PERIOD
	WHERE SW_ID_SYSTEM = @SYS_ID AND PR_DATE = @PR_DATE AND SW_PROBLEM = @PROBLEM

	SET @result = @result *
		(
			SELECT DISTINCT SNCC_WEIGHT
			FROM
				dbo.SystemNetCoef
				INNER JOIN dbo.PeriodTable ON PR_ID = SNCC_ID_PERIOD
				INNER JOIN dbo.SystemNetTable ON SNCC_ID_SN = SN_ID
			WHERE SN_GROUP = @NT_ID AND PR_DATE = @PR_DATE
		)

	RETURN ISNULL(@result, 0)
END

GO
