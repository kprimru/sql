USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INVOICE_GET_LAST_NUM]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INVOICE_GET_LAST_NUM]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INVOICE_GET_LAST_NUM]
	@date SMALLDATETIME,
	@orgid SMALLINT
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

		DECLARE @insnum INT

		SELECT @insnum = MAX(INS_NUM) + 1
		FROM dbo.InvoiceSaleTable
		WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @date),2)
			AND INS_ID_ORG = @orgid


		IF @insnum IS NULL
			SET @insnum = 1

		SELECT @insnum AS INS_NUM, RIGHT(DATEPART(yy, @date),2) AS INS_NUM_YEAR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_GET_LAST_NUM] TO rl_invoice_w;
GO
