USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.ContractTable
	WHERE ContractID = @ID
END