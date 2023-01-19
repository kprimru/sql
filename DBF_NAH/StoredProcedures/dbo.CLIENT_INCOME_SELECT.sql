USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_INCOME_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_INCOME_SELECT]  AS SELECT 1')
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_INCOME_SELECT]
	@clientid INT
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
			IN_ID, IN_DATE, IN_SUM, IN_PAY_DATE, IN_PAY_NUM, IN_REST, IN_PRIMARY, (CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM,
			ORG_PSEDO
		FROM
			dbo.IncomeView LEFT OUTER JOIN
			dbo.InvoiceSaleTable ON INS_ID = IN_ID_INVOICE
		WHERE IN_ID_CLIENT = @clientid
		ORDER BY IN_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_INCOME_SELECT] TO rl_income_r;
GO
