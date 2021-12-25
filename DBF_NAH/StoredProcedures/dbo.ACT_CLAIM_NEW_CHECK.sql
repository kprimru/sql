USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CLAIM_NEW_CHECK]
	@DT	DATETIME = NULL OUTPUT
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

		SELECT COUNT(*) AS CNT
		FROM [PC275-SQL\ALPHA].ClientDB.dbo.ActCalc
		WHERE ISNULL(CALC_STATUS, '') <> 'Расчитан полностью'
			AND
				(
					ISNULL(CONFIRM_NEED,0) = 0
					OR
					CONFIRM_NEED = 1 AND CONFIRM_DATE IS NOT NULL
				)
			AND STATUS = 1
			AND (@DT IS NULL OR CONVERT(DATETIME, CONVERT(NVARCHAR(128), DATE, 120), 120) > @DT)

		SELECT @DT = MAX(DATE)
		FROM [PC275-SQL\ALPHA].ClientDB.dbo.ActCalc
		WHERE ISNULL(CALC_STATUS, '') <> 'Расчитан полностью'
			AND
				(
					ISNULL(CONFIRM_NEED,0) = 0
					OR
					CONFIRM_NEED = 1 AND CONFIRM_DATE IS NOT NULL
				)
			AND STATUS = 1
			--AND (@DT IS NULL OR DATE > @DT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_CLAIM_NEW_CHECK] TO rl_act_w;
GO
