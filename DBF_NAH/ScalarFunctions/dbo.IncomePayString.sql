USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[IncomePayString]
(
	@CL_ID	INT,
	@DIS_ID	INT,
	@DATE SMALLDATETIME
)
RETURNS VARCHAR(150)
AS
BEGIN
	DECLARE @RESULT VARCHAR(50)

	SET @RESULT = ''

	SELECT @RESULT = @RESULT + CONVERT(VARCHAR(20), IN_PAY_NUM) + ','
	FROM
		(
			SELECT DISTINCT IN_PAY_NUM
			FROM
				dbo.IncomeTable INNER JOIN
				dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
			WHERE @CL_ID = IN_ID_CLIENT AND IN_DATE = @DATE AND ID_ID_DISTR = @DIS_ID
		) AS o_O
	ORDER BY IN_PAY_NUM

	IF LEN(@RESULT) > 1
		SET @RESULT = LEFT(@RESULT, LEN(@RESULT) - 1)

	RETURN @RESULT
END

GO