USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DOC_SALE_OBJECT_DEF_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_EDIT]  AS SELECT 1')
GO





/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_EDIT]
	@id SMALLINT,
	@soid SMALLINT,
	@docid SMALLINT,
	@goodid SMALLINT,
	@unitid SMALLINT,
	@print BIT,
	@active BIT = 1
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

		UPDATE dbo.DocumentSaleObjectDefaultTable
		SET DSD_ID_SO = @soid,
			DSD_ID_DOC = @docid,
			DSD_ID_GOOD	= @goodid,
			DSD_ID_UNIT = @unitid,
			DSD_PRINT = @print,
			DSD_ACTIVE = @active
		WHERE DSD_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DOC_SALE_OBJECT_DEF_EDIT] TO rl_doc_sale_object_def_w;
GO
