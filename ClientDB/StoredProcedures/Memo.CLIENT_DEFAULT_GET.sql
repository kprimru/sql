USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[CLIENT_DEFAULT_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 PayTypeID, ContractPayID
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ContractTable b ON a.ClientID = b.CLientID
	WHERE a.CLientID = @ID
	ORDER BY ContractBegin DESC, ContractID DESC
END
