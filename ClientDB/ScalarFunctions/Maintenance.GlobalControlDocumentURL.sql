USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalControlDocumentURL]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalControlDocumentURL] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Maintenance].[GlobalControlDocumentURL]
()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RES VARCHAR(500)

	SELECT @RES = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'CONTROL_DOCUMENT_URL'

	RETURN @RES
END
GO
