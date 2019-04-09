USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_DOCUMENT_SELECT]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ID, a.ID_TYPE, b.NAME, a.DATE, a.NOTE, a.FIXED
	FROM 
		dbo.ContractDocument a
		INNER JOIN dbo.DocumentType b ON a.ID_TYPE = b.ID
	WHERE ID_CONTRACT = @ID AND STATUS = 1
	ORDER BY DATE DESC
END
