USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[KBU_CALC]
	@PR_ID	SMALLINT,
	@PORK	DECIMAL(10, 4),
	@LO		DECIMAL(10, 4),
	@HIGH	DECIMAL(10, 4)
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

		DECLARE @RES	DECIMAL(10, 4)

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE 
		FROM dbo.PeriodTable 
		WHERE PR_ID = @PR_ID

		IF @PR_DATE >= '20120601'
		BEGIN
			IF @PORK >= @HIGH + 10
				SET @RES = 0.5
			ELSE IF (@PORK > @HIGH) AND (@PORK < @HIGH + 10)
				SET @RES = 1 - 0.5 * (@PORK - @HIGH) / 10
			ELSE IF (@PORK <= @HIGH) AND (@PORK >= @LO)
				SET @RES = 1
			ELSE IF (@PORK < @LO) AND (@PORK >= @LO - 10)
				SET @RES = 1.5 - 0.5 * (@PORK + 10 - @LO) / 10
			ELSE IF @PORK < @LO - 10
				SET @RES = 1.5 - 0.5 * (@PORK + 10 - @LO) / 13.1
			ELSE
				SET @RES = NULL
		END

		SELECT ROUND(@RES, 4) AS KBU
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Ric].[KBU_CALC] TO rl_ric_kbu;
GO