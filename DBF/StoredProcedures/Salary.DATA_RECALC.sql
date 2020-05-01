USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[DATA_RECALC]
	@CALC				BIT,
	@KGS				DECIMAL(8, 4),
	@CL_TERR			VARCHAR(10),
	@CLIENT_TOTAL_PRICE	MONEY,
	@TO_PRICE			MONEY,
	@TO_COUNT			INT,
	@SYS_COUNT			INT,
	@KOB				DECIMAL(8, 4),
	@CPS_PERCENT		DECIMAL(8, 4),
	@CPS_MIN			MONEY,
	@CPS_MAX			MONEY,
	@CPS_PAY			BIT,
	@CPS_INET			BIT,
	@CPS_ACT			BIT,
	@PAY				BIT,
	@UPDATES			BIT,
	@ACT				BIT,
	@INET				BIT
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

		DECLARE @TO_RESULT		MONEY
		DECLARE @TO_HANDS		MONEY
		DECLARE @TO_PAY_RESULT	MONEY
		DECLARE @TO_PAY_HANDS	MONEY		
		
		DECLARE @TO_CALC	MONEY
		
		SET @TO_CALC = ROUND(ROUND(@CLIENT_TOTAL_PRICE / ISNULL(@TO_COUNT, 1), 2) * @CPS_PERCENT/100, 2)
		
		IF @KOB IS NOT NULL
		BEGIN
			SELECT TOP 1 @KOB = PC_VALUE 
			FROM dbo.PayCoefTable 
			WHERE @SYS_COUNT BETWEEN PC_START AND PC_END
		
			IF @INET = 1 AND @CPS_INET = 1
				SET @KOB = 1
			ELSE IF @CPS_MIN IS NULL AND @CPS_MAX IS NULL
				SET @KOB = 1
			ELSE
			BEGIN
				IF @CPS_MAX IS NOT NULL AND @TO_CALC > @CPS_MAX
					SET @KOB = 1
				ELSE
				BEGIN
					IF @KGS > 70 AND @CL_TERR = '��' AND @CPS_MIN IS NOT NULL AND @CPS_MIN > @TO_CALC
						SET @TO_CALC = 230
					IF @CL_TERR = '��' AND @CPS_MIN IS NOT NULL AND @CPS_MIN > @TO_CALC
						SET @TO_CALC = 230				
				END
			END
		END
		
		IF @TO_CALC IS NULL AND @CPS_MIN IS NOT NULL
			SET @TO_CALC = @CPS_MIN
		
		SET @TO_RESULT = ROUND(@TO_CALC * @KOB, 0)
		SET @TO_HANDS = ROUND(@TO_RESULT * 0.87, 0)
		
		IF (@PAY = 0 AND @CPS_PAY = 1) OR @UPDATES = 0
			SET @TO_PAY_RESULT = 0
		ELSE
			SET @TO_PAY_RESULT = @TO_RESULT
			
		SET @TO_PAY_HANDS = ROUND(@TO_PAY_RESULT * 0.87, 0)
		
		SELECT 
			CONVERT(BIT, CASE ISNULL(@TO_PAY_RESULT, 0) WHEN 0 THEN 0 ELSE 1 END) AS CALC,
			ROUND(@CLIENT_TOTAL_PRICE / ISNULL(@TO_COUNT, 1), 2) AS TO_PRICE,
			ROUND(ROUND(@CLIENT_TOTAL_PRICE / ISNULL(@TO_COUNT, 1), 2) * @CPS_PERCENT/100, 2) AS TO_CALC,
			@KOB AS KOB, @TO_RESULT AS TO_RESULT, @TO_HANDS AS TO_HANDS, @TO_PAY_RESULT AS TO_PAY_RESULT, @TO_PAY_HANDS AS TO_PAY_HANDS
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Salary].[DATA_RECALC] TO rl_courier_pay;
GO