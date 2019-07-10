USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[BANK_SELECT]    
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
			BA_ID, BA_BIK, BA_NAME, CT_NAME, CT_ID, 
			BA_PHONE, BA_MFO, BA_CALC, BA_LORO
	FROM 
		dbo.BankTable bt LEFT OUTER JOIN
		dbo.CityTable ct ON ct.CT_ID = bt.BA_ID_CITY
	WHERE BA_ACTIVE = ISNULL(@active, BA_ACTIVE)
	ORDER BY BA_NAME, CT_NAME

	SET NOCOUNT OFF
END





