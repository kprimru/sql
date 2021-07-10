USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET]
AS
BEGIN
	SET NOCOUNT ON;

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
END



GO
GRANT EXECUTE ON [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET] TO rl_doc_sale_object_def_r;
GO