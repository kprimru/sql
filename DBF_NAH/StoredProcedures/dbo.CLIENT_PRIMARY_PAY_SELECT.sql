USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_PRIMARY_PAY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_PRIMARY_PAY_SELECT]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PRIMARY_PAY_SELECT]
  @clientid INT
AS
BEGIN
	SET NOCOUNT ON

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
			PRP_ID, DIS_STR, DIS_ID, PRP_DATE, PRP_PRICE, TX_ID, TX_NAME, TX_PERCENT, PRP_TAX_PRICE,
			PRP_TOTAL_PRICE, PRP_DOC,
			PRP_COMMENT, (CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM,
			ORG_PSEDO
		FROM
			dbo.PrimaryPayView
			LEFT OUTER JOIN dbo.InvoiceSaleTable ON PRP_ID_INVOICE = INS_ID
			LEFT OUTER JOIN dbo.OrganizationTable ON ORG_ID = PRP_ID_ORG
		WHERE PRP_ID_CLIENT = @clientid
			--AND DIS_ACTIVE = 1
		ORDER BY DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_PRIMARY_PAY_SELECT] TO rl_primary_pay_r;
GO
