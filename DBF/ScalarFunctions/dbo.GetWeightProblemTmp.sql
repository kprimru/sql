USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetWeightProblemTmp]
(
	@SYS_ID VARCHAR(50),
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
		INNER JOIN dbo.SystemTable ON SYS_ID = SW_ID_SYSTEM		
	WHERE SYS_GROUP = @SYS_ID AND PR_DATE = @PR_DATE AND SW_PROBLEM = @PROBLEM

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