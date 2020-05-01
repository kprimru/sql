USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[IncomeSystemString]
(
	@CL_ID	INT,
	@IN_DATE SMALLDATETIME,
	@SYS_ID	INT
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RESULT VARCHAR(50)

	SELECT @RESULT = DATENAME(MONTH, MIN(PR_DATE))
	FROM 
		dbo.IncomeTable INNER JOIN
		dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
		dbo.PeriodTable ON PR_ID = ID_ID_PERIOD INNER JOIN
		dbo.DistrTable ON DIS_ID = ID_ID_DISTR
	WHERE IN_ID_CLIENT = @CL_ID AND IN_DATE = @IN_DATE AND DIS_ID_SYSTEM = @SYS_ID
	
	DECLARE @TMP VARCHAR(50)

	SELECT @TMP = DATENAME(MONTH, MAX(PR_DATE))
	FROM 
		dbo.IncomeTable INNER JOIN
		dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
		dbo.PeriodTable ON PR_ID = ID_ID_PERIOD INNER JOIN
		dbo.DistrTable ON DIS_ID = ID_ID_DISTR
	WHERE IN_ID_CLIENT = @CL_ID AND IN_DATE = @IN_DATE AND DIS_ID_SYSTEM = @SYS_ID

	IF @RESULT <> @TMP
		SET @RESULT = @RESULT + '-' + @TMP

	RETURN @RESULT
END
