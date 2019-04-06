USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_BANK_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.InfoBankID, InfoBankShortName, InfoBankName, 
		CONVERT(BIT,
			(
				SELECT COUNT(*)
				FROM dbo.SystemBankTable b 
				WHERE a.InfoBankID = b.InfoBankID 
					AND SystemID = @ID
			)
		) AS InfoBankChecked
	FROM 
		dbo.InfoBankTable a		
	ORDER BY InfoBankShortName
END