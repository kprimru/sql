USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[BANK_EDIT] 
	@bankid  SMALLINT,
	@bankname VARCHAR(150),
	@cityid INT,
	@bankphone VARCHAR(100),	
	@bankmfo VARCHAR(100),	
	@bankcalc VARCHAR(100),	
	@bik VARCHAR(50),
	@loro VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.BankTable 
	SET BA_NAME = @bankname, 
		BA_ID_CITY = @cityid, 
		BA_PHONE = @bankphone, 
		BA_CALC = @bankcalc, 
		BA_MFO = @bankmfo,
		BA_BIK = @bik,
		BA_LORO = @loro,
		BA_ACTIVE = @active
	WHERE BA_ID = @bankid

	SET NOCOUNT OFF
END


