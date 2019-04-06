USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INFO_BANK_SELECT]
	@FILTER	VARCHAR(150) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		InfoBankID, InfoBankShortName, InfoBankName, InfoBankDaily, InfoBankActual,
		InfoBankStart,
		dbo.FileByteSizeToStr(
			(
				SELECT TOP 1 IBS_SIZE
				FROM dbo.InfoBankSizeView WITH(NOEXPAND)
				WHERE IBF_ID_IB = InfoBankID
				ORDER BY IBS_DATE DESC
			)
		) AS IBS_SIZE
	FROM dbo.InfoBankTable
	WHERE @FILTER IS NULL
		OR InfoBankShortName LIKE @FILTER
		OR InfoBankName LIKE @FILTER
		OR InfoBankFullName LIKE @FILTER
	ORDER BY InfoBankShortName
END
