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

CREATE PROCEDURE [dbo].[BANK_ADD] 
	@bankname VARCHAR(150),
	@cityid INT,
	@bankphone VARCHAR(100),
	@bankcalc VARCHAR(100),
	@bankmfo VARCHAR(100),
	@bik VARCHAR(50),
	@loro VARCHAR(50),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.BankTable(BA_NAME, BA_ID_CITY, BA_PHONE, BA_CALC, BA_MFO, BA_BIK, BA_LORO, BA_ACTIVE, BA_OLD_CODE) 
	VALUES (@bankname, @cityid, @bankphone, @bankcalc, @bankmfo, @bik, @loro, @active, @oldcode)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END