USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PROTOCOL_DETAIL]
	@ID		INT,
	@TXT	VARCHAR(MAX) OUTPUT
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

		SELECT @TXT =
			CONVERT(VARCHAR(20), PR_DATE, 104) +
				':' + DIS_STR + ' - ' + dbo.MoneyFormat(AD_TOTAL_PRICE)
		FROM
			dbo.ActDistrTable
			INNER JOIN dbo.DistrView WITH(NOEXPAND) ON AD_ID_DISTR = DIS_ID
			INNER JOIN dbo.PeriodTable ON AD_ID_PERIOD = PR_ID
		WHERE AD_ID = @ID

		SET @TXT = LEFT(@TXT, LEN(@TXT) - 1)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
