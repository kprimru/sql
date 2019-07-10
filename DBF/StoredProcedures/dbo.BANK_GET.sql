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

CREATE PROCEDURE [dbo].[BANK_GET]  
	@bankid INT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT 
			BA_ID, BA_NAME, CT_NAME, CT_ID, BA_PHONE, 
			BA_MFO, BA_CALC, BA_MFO, BA_BIK, BA_LORO, BA_ACTIVE  
	FROM 
		dbo.BankTable bt LEFT OUTER JOIN
		dbo.CityTable ct ON ct.CT_ID = bt.BA_ID_CITY
	WHERE BA_ID = @bankid 	

	SET NOCOUNT OFF
END





