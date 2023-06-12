USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_DELIVERY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_DELIVERY]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_DELIVERY]
	@incomeid INT,
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

		UPDATE dbo.IncomeTable
		SET IN_ID_CLIENT = @clientid,
			IN_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE IN_ID = @incomeid

		UPDATE dbo.InvoiceSaleTable
		SET INS_ID_CLIENT = @clientid,
			INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE INS_ID =
			(
				SELECT IN_ID_INVOICE
				FROM dbo.IncomeTable
				WHERE IN_ID = @incomeid
			)

		UPDATE dbo.SaldoTable
		SET SL_ID_CLIENT = @clientid
		WHERE SL_ID_IN_DIS IN
			(
				SELECT ID_ID
				FROM dbo.IncomeDistrTable
				WHERE ID_ID_INCOME = @incomeid
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_DELIVERY] TO rl_income_w;
GO
