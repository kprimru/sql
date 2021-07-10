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

	UPDATE dbo.DocumentSaleObjectDefaultTable
	SET DSD_ID_SO = @soid,
		DSD_ID_DOC = @docid,
		DSD_ID_GOOD	= @goodid,
		DSD_ID_UNIT = @unitid,
		DSD_PRINT = @print,
		DSD_ACTIVE = @active
	WHERE DSD_ID = @id
END






GO
GRANT EXECUTE ON [dbo].[DOC_SALE_OBJECT_DEF_EDIT] TO rl_doc_sale_object_def_w;
GO