USE [DBF]
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

CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.DocumentSaleObjectDefaultTable WHERE DSD_ID = @id
END


