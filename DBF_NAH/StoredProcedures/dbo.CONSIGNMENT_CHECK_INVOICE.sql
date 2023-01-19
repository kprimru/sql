USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_CHECK_INVOICE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_CHECK_INVOICE]  AS SELECT 1')
GO



/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_CHECK_INVOICE]
	@consid INT
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

		SELECT CSG_DATE, CSG_ID
		FROM dbo.ConsignmentTable
		WHERE CSG_ID_INVOICE IS NOT NULL AND CSG_ID = @consid AND
			(
				SELECT INS_RESERVE
				FROM dbo.InvoiceSaleTable
				WHERE INS_ID = CSG_ID_INVOICE
			) = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_CHECK_INVOICE] TO rl_consignment_w;
GO
