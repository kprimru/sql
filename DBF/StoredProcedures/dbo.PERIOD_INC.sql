USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PERIOD_INC]
	@PR_ID	SMALLINT,
	@CNT	SMALLINT,
	@PR_OUT	SMALLINT OUTPUT,
	@PR_TXT	VARCHAR(50) OUTPUT
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

		SELECT @PR_OUT = PR_ID, @PR_TXT = PR_NAME
		FROM dbo.PeriodTable
		WHERE PR_DATE = (SELECT DATEADD(MONTH, @CNT, PR_DATE) FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_INC] TO public;
GO
