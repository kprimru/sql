USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PLUG_SET_ACT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PLUG_SET_ACT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[PLUG_SET_ACT]
	@actid INT
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

		UPDATE dbo.ActTable
		SET ACT_ID_INVOICE =
			(
				SELECT INS_ID
				FROM dbo.InvoiceSaleTable
				WHERE INS_NUM = '0'
					AND INS_NUM_YEAR = '0'
			)
		WHERE ACT_ID = @actid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PLUG_SET_ACT] TO rl_invoice_w;
GO
