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

CREATE PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_DELETE]
	@cdsid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.ClientDocumentSettingsTable	
	WHERE CDS_ID = @cdsid				
END
