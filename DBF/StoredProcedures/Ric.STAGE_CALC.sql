USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[STAGE_CALC]
	@PR_ALG	SMALLINT,
	@GS		DECIMAL(10, 4),
	@GNA	DECIMAL(10, 4),
	@STAGE	DECIMAL(10, 4)
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @LO	DECIMAL(10, 4)
		DECLARE @HIGH	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			SELECT @LO = MIN(VAL)
			FROM
				(
					SELECT @GS - @STAGE AS VAL
					UNION ALL
					SELECT @GNA - 2 AS VAL
				) AS o_O

			SELECT @HIGH = MIN(VAL)
			FROM
				(
					SELECT @GS AS VAL
					UNION ALL
					SELECT @GNA + @STAGE AS VAL
				) AS o_O
		END

		SELECT @LO AS LO, @HIGH AS HIGH

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[STAGE_CALC] TO rl_ric_kbu;
GO