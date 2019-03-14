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

CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_DEFAULT_GET]
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


