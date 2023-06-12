﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_CALC_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_CALC_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SERVICE_CALC_SAVE]
	@COURIER		SMALLINT,
	@PERIOD			SMALLINT,
	@ID_CLIENT		INT,
	@CL_NAME		VARCHAR(500),
	@TO_ID			INT,
	@TO_NAME		VARCHAR(500),
	@ID_CITY		SMALLINT,
	@CT_NAME		VARCHAR(150),
	@ID_TYPE		SMALLINT,
	@KGS			DECIMAL(8, 4),
	@ID_PERIOD		SMALLINT,
	@CL_TERR		VARCHAR(10),
	@CLIENT_TOTAL_PRICE	MONEY,
	@TO_COUNT		SMALLINT,
	@TO_PRICE		MONEY,
	@CPS_PERCENT	DECIMAL(8, 4),
	@TO_CALC		MONEY,
	@CPS_MIN		MONEY,
	@CPS_MAX		MONEY,
	@CPS_INET		BIT,
	@CPS_PAY		BIT,
	@CPS_COEF		BIT,
	@CPS_ACT		BIT,
	@SYS_COUNT		SMALLINT,
	@KOB			DECIMAL(8, 4),
	@PAY			BIT,
	@CALC			BIT,
	@NOTE			VARCHAR(MAX),
	@UPDATES		BIT,
	@ACT			BIT,
	@INET			BIT,
	@TO_RESULT		MONEY,
	@TO_HANDS		MONEY,
	@TO_PAY_RESULT	MONEY,
	@TO_PAY_HANDS	MONEY,
	@COEF			DECIMAL(8,4) = NULL,
	@TO_RANGE       DECIMAL(8,4) = NULL,
	@TO_SERVICE     VarChar(50) = NULL,
	@TO_SERVICE_COEF DECIMAL(8,4) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @ID_SALARY	UNIQUEIDENTIFIER

		SELECT @ID_SALARY = ID
		FROM Salary.Service
		WHERE ID_COURIER = @COURIER
			AND ID_PERIOD = @PERIOD

		IF @ID_SALARY IS NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Salary.Service(ID_COURIER, ID_PERIOD)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@COURIER, @PERIOD)

			SELECT @ID_SALARY = ID
			FROM @TBL
		END

		UPDATE Salary.Service
		SET COEF = @COEF
		WHERE ID = @ID_SALARY

		DECLARE @HOLD BIT

		IF @UPDATES = 0
			SET @HOLD = 0
		ELSE
			SET @HOLD = 1

		INSERT INTO Salary.ServiceDetail(
					ID_SALARY, ID_CLIENT, CL_NAME, TO_ID, TO_NAME, ID_CITY, CT_NAME, ID_TYPE, KGS, ID_PERIOD, CL_TERR,
					CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, TO_CALC, CPS_MIN, CPS_MAX, CPS_INET, CPS_PAY, CPS_COEF, CPS_ACT,
					SYS_COUNT, KOB, PAY, CALC, NOTE, UPDATES, ACT, INET,
					TO_RESULT, TO_HANDS, TO_PAY_RESULT, TO_PAY_HANDS, HOLD, TO_RANGE, TO_SERVICE, TO_SERVICE_COEF)
			VALUES(
					@ID_SALARY, @ID_CLIENT, @CL_NAME, @TO_ID, @TO_NAME, @ID_CITY, @CT_NAME, @ID_TYPE, @KGS, @ID_PERIOD, @CL_TERR,
					@CLIENT_TOTAL_PRICE, @TO_COUNT, @TO_PRICE, @CPS_PERCENT, @TO_CALC, @CPS_MIN, @CPS_MAX, @CPS_INET, @CPS_PAY, @CPS_COEF, @CPS_ACT,
					@SYS_COUNT, @KOB, @PAY, @CALC, @NOTE, @UPDATES, @ACT, @INET,
					@TO_RESULT, @TO_HANDS, @TO_PAY_RESULT, @TO_PAY_HANDS, @HOLD, @TO_RANGE, @TO_SERVICE, @TO_SERVICE_COEF)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Salary].[SERVICE_CALC_SAVE] TO public;
GRANT EXECUTE ON [Salary].[SERVICE_CALC_SAVE] TO rl_courier_pay;
GO
