USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOCUMENT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME
	FROM dbo.DocumentType
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER		
	ORDER BY NAME
END
