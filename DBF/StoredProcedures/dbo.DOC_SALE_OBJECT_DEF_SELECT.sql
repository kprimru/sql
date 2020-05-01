USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			
Дата создания:  	
Описание:		
*/

ALTER PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_SELECT]
	@active BIT = NULL
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

		SELECT DSD_ID, SO_NAME, DOC_NAME, GD_NAME, DSD_PRINT, UN_NAME
		FROM 
			dbo.DocumentSaleObjectDefaultTable INNER JOIN
			dbo.SaleObjectTable ON SO_ID = DSD_ID_SO INNER JOIN
			dbo.DocumentTable ON DOC_ID = DSD_ID_DOC INNER JOIN
			dbo.GoodTable ON GD_ID = DSD_ID_GOOD INNER JOIN
			dbo.UnitTable ON UN_ID = DSD_ID_UNIT
		WHERE DSD_ACTIVE = ISNULL(@active, DSD_ACTIVE)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DOC_SALE_OBJECT_DEF_SELECT] TO rl_doc_sale_object_def_r;
GO