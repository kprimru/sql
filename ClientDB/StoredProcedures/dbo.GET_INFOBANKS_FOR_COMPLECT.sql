USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT] 
	@SYSID INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankPath
	FROM dbo.InfoBankTable
	WHERE
		InfoBankID IN
			(
				SELECT InfoBankID
				FROM dbo.SystemBankTable 
				--WHERE  (SystemID = @SYSID) AND (Required IN (1, 2)) --ДОФ будем добавлять программно
                WHERE  (SystemID = @SYSID) AND (Required =1)  
			)
		AND InfoBankActive = 1
END