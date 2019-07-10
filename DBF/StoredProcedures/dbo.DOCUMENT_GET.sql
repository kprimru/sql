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

CREATE PROCEDURE [dbo].[DOCUMENT_GET]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DOC_ID, DOC_NAME, DOC_PSEDO, DOC_ACTIVE
	FROM 
		dbo.DocumentTable 
	WHERE DOC_ID = @id
END




