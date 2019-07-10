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

CREATE PROCEDURE [dbo].[DOCUMENT_ADD]
	@name VARCHAR(100),	
	@psedo VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.DocumentTable(DOC_NAME, DOC_PSEDO, DOC_ACTIVE)
	VALUES (@name, @psedo, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END


