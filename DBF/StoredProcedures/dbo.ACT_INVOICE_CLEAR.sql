USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_INVOICE_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_INVOICE_CLEAR]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[ACT_INVOICE_CLEAR]
	@ACT_ID INT
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

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Отвязка от счета-фактуры', 'Был номер ' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
			FROM
				dbo.ActTable a
				INNER JOIN dbo.InvoiceSaleTable b ON a.ACT_ID_INVOICE = b.INS_ID
			WHERE a.ACT_ID = @ACT_ID

		UPDATE dbo.ActTable
		SET ACT_ID_INVOICE = NULL
		WHERE ACT_ID = @ACT_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_INVOICE_CLEAR] TO rl_act_w;
GO
