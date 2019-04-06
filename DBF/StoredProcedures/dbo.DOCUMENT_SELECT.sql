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

CREATE PROCEDURE [dbo].[DOCUMENT_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DOC_ID, DOC_NAME
	FROM 
		dbo.DocumentTable 
	WHERE DOC_ACTIVE = ISNULL(@active, DOC_ACTIVE)
END

