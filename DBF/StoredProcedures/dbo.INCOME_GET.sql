USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_GET]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_GET]
	@inid INT
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

		SELECT IN_DATE, IN_SUM, IN_PAY_DATE, IN_PAY_NUM, IN_PRIMARY
		FROM dbo.IncomeTable
		WHERE IN_ID = @inid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_GET] TO rl_income_r;
GO
