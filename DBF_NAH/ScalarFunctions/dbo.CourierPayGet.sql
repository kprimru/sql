USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[CourierPayGet]
(
	@TO_ID INT,
	@PERIOD SMALLINT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @RESULT MONEY

	DECLARE @TYPE SMALLINT

	SELECT @TYPE = CL_ID_TYPE
	FROM dbo.ClientTable
	WHERE CL_ID = (SELECT TO_ID_CLIENT FROM dbo.TOTable WHERE TO_ID = @TO_ID)

	IF @TYPE IN (1, 2, 3, 5)
	BEGIN
		SELECT @RESULT = SUM(BD_PRICE)
		FROM
			dbo.TOTable INNER JOIN
			dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
			dbo.BillTable ON BL_ID_CLIENT = TO_ID_CLIENT INNER JOIN
			dbo.BillDistrTable ON BD_ID_BILL = BL_ID AND BD_ID_DISTR = DIS_ID
		WHERE BL_ID_PERIOD = @PERIOD
			AND TO_ID = @TO_ID

		SET @RESULT = @RESULT / 5
	END
	ELSE IF @TYPE = 4
	BEGIN
		SET @RESULT = 230
	END
	ELSE IF @TYPE = 6
	BEGIN
		DECLARE @CL_ID INT
		DECLARE @COEF DECIMAL(8, 4)
		DECLARE @SYS_COUNT SMALLINT

		SELECT @CL_ID = TO_ID_CLIENT
		FROM TOTable
		WHERE TO_ID = @TO_ID

		SELECT
			@RESULT = SUM(BD_PRICE)
		FROM 
			dbo.BillTable INNER JOIN
			dbo.BillDistrTable ON BD_ID_BILL = BL_ID
		WHERE BL_ID_PERIOD = @PERIOD
			AND BL_ID_CLIENT = @CL_ID

		DECLARE @TO_COUNT SMALLINT

		SELECT @TO_COUNT = COUNT(*)
		FROM TOTable
		WHERE EXISTS
			(
				SELECT *
				FROM
					dbo.TODistrTable INNER JOIN
					dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
					dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
								AND RN_DISTR_NUM = DIS_NUM
								AND RN_COMP_NUM = DIS_COMP_NUM
				WHERE TD_ID_TO = TO_ID
					AND RN_SERVICE = 0
			) AND TO_ID_CLIENT = @CL_ID

		SELECT @SYS_COUNT = COUNT(*)
		FROM
			dbo.TODistrTable INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_TO INNER JOIN
			dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
						AND RN_DISTR_NUM = DIS_NUM
						AND RN_COMP_NUM = DIS_COMP_NUM
		WHERE TD_ID_TO = @TO_ID
			AND RN_SERVICE = 0

		SELECT @COEF = dbo.PayCoefGet(@SYS_COUNT)

		SET @RESULT = @COEF * @RESULT / @TO_COUNT

		IF @RESULT > 500
		BEGIN
			SET @COEF = 1
			SET @RESULT = @COEF * @RESULT / @TO_COUNT
		END

		IF @RESULT < 230
			SET @RESULT = 230
	END

	RETURN @RESULT
END

GO
