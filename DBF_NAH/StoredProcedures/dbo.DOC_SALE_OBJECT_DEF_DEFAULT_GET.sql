USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET]  AS SELECT 1')
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET]
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

		SELECT DOC_NAME, DOC_ID, SO_NAME, SO_ID, GD_ID, GD_NAME, UN_ID, UN_NAME
		FROM
			dbo.DocumentTable,
			dbo.SaleObjectTable,
			dbo.GoodTable,
			dbo.UnitTable
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DocumentSaleObjectDefaultTable
				WHERE DSD_ID_SO = SO_ID AND DSD_ID_DOC = DOC_ID
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
GRANT EXECUTE ON [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET] TO rl_doc_sale_object_def_r;
GO
