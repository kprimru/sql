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

CREATE PROCEDURE [dbo].[DOCUMENT_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@psedo VARCHAR(50),	
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DocumentTable
	SET DOC_NAME = @name,
		DOC_PSEDO = @psedo,
		DOC_ACTIVE = @active
	WHERE DOC_ID = @id
END


