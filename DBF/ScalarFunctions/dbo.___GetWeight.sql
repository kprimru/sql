USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetWeight]
(
	@SYS_ID INT,
	@NT_ID	INT,
	@PR_DATE SMALLDATETIME
)
RETURNS DECIMAL(8, 4)
AS
BEGIN
	
	DECLARE @result DECIMAL(8, 4)
	
	SELECT @result = SW_WEIGHT
	FROM	
		dbo.SystemWeightTable INNER JOIN
		dbo.PeriodTable ON PR_ID = SW_ID_PERIOD
	WHERE SW_ID_SYSTEM = @SYS_ID AND PR_DATE = @PR_DATE AND SW_PROBLEM = 0

	SELECT @result = @result * SNCC_WEIGHT
	FROM 
		dbo.SystemNetCoef INNER JOIN
		dbo.PeriodTable ON PR_ID = SNCC_ID_PERIOD
	WHERE SNCC_ID_SN = @NT_ID AND PR_DATE = @PR_DATE
	
	RETURN @result
END
GRANT EXECUTE ON [dbo].[___GetWeight] TO rl_reg_node_report_r;
GO