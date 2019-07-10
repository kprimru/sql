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

CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_GET]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DSD_ID, DOC_ID, DOC_NAME, SO_ID, SO_NAME, GD_ID, GD_NAME, DSD_PRINT, DSD_ACTIVE,
		UN_ID, UN_NAME
	FROM 
		dbo.DocumentSaleObjectDefaultTable INNER JOIN
		dbo.SaleObjectTable ON SO_ID = DSD_ID_SO INNER JOIN
		dbo.DocumentTable ON DOC_ID = DSD_ID_DOC INNER JOIN
		dbo.GoodTable ON GD_ID = DSD_ID_GOOD INNER JOIN
		dbo.UnitTable ON UN_ID = DSD_ID_UNIT
	WHERE DSD_ID = @id
END






