USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[FORM_GET]
	@ID UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NUM, NAME, FILE_PATH
	FROM Contract.Forms	
	WHERE ID = @ID
END
