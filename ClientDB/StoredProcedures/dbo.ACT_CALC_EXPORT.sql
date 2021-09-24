USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CALC_EXPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		SET @END = DATEADD(DAY, 1, @END)

		SELECT
			ID,
			SERVICE + '_' + REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(64), DATE, 120), '-', '_'), ':', '_'), ' ', '_') + '.xml' AS FNAME,
			CONVERT(VARCHAR(MAX), (
				SELECT SYS_REG AS s, DISTR AS d, COMP AS c, CONVERT(VARCHAR(32), MON, 112) AS m
				FROM dbo.ActCalcDetail b
				WHERE a.ID = b.ID_MASTER
				FOR XML PATH('i'), ROOT('act_claim')
			)) AS DATA
		FROM dbo.ActCalc a
		WHERE STATUS = 1
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE < @END OR @END IS NULL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CALC_EXPORT] TO rl_act_calc;
GO
