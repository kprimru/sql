USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CLAIM_SELECT]
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

		SELECT
			ID, DATE, USR, SERVICE, DT, CONFIRM_USER, CONFIRM_DATE, CONFIRM_NEED, CONFIRM_NOTE
		FROM
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY DATE) AS ID, DATE, USR, SERVICE,
					CONVERT(VARCHAR(20), DATE, 104) + ' ' + CONVERT(VARCHAR(20), DATE, 108) AS DT,
					CONFIRM_USER, CONFIRM_DATE, CONFIRM_NEED, CALC_STATUS,
					CASE WHEN CONFIRM_NEED = 1 AND CONFIRM_USER IS NULL THEN 'НЕ ПОДТВЕРЖДЕНА!!!' ELSE '' END AS CONFIRM_NOTE
				FROM [PC275-SQL\ALPHA].ClientDB.dbo.ActCalc
				WHERE STATUS = 1
			) AS o_O
		WHERE ISNULL(CALC_STATUS, 'Не расчитана') <> 'Расчитан полностью'
			AND DATE >= DATEADD(MONTH, -3, GETDATE())
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CLAIM_SELECT] TO rl_act_w;
GO
