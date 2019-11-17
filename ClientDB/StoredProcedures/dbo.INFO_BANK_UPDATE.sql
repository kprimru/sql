USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INFO_BANK_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(20),
	@SHORT	VARCHAR(20),
	@FULL	VARCHAR(250),
	@ORDER	INT,
	@PATH	VARCHAR(255),
	@ACTIVE	BIT,
	@DAILY	BIT,
	@ACTUAL	BIT,
	@START	SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.InfoBankTable
	SET InfoBankName = @NAME,
		InfoBankShortName = @SHORT,
		InfoBankFullName = @FULL,
		InfoBankOrder = @ORDER,
		InfoBankPath = @PATH,
		InfoBankActive = @ACTIVE,
		InfoBankDaily = @DAILY,
		InfoBankActual = @ACTUAL,
		InfoBankStart = ISNULL(@START, InfoBankStart)
	WHERE InfoBankID = @ID
END
