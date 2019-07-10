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

CREATE PROCEDURE [dbo].[DOCUMENT_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.DocumentTable WHERE DOC_ID = @id
END

