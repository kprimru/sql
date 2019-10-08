USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SYSTEM_BANKS_SELECT]
	@SYSID		INT,
	@DTYPEID	INT
AS
BEGIN
	SELECT InfoBank_ID, InfoBankName, InfoBankShortName, Required, InfoBankOrder
	FROM dbo.SystemInfoBanksView WITH(NOEXPAND)
	WHERE System_Id = @SYSID AND DistrType_Id = @DTYPEID
END

