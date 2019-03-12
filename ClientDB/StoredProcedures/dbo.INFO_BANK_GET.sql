USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[INFO_BANK_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName, 
		InfoBankOrder, InfoBankPath, InfoBankActive, InfoBankDaily, 
		InfoBankActual, InfoBankStart
	FROM dbo.InfoBankTable
	WHERE InfoBankID = @ID
END
