USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[PLUG_DEL_ACT]
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
		SET ACT_ID_INVOICE = NULL
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
GRANT EXECUTE ON [dbo].[PLUG_DEL_ACT] TO rl_invoice_w;
GO
