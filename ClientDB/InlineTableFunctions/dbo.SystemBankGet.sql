USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[SystemBankGet]
(
	-- Id системы
	@System		Int,
	-- Id типа сети из таблицы dbo.DistrTypeTable
	@DistrType	Int
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		InfoBankID = InfoBank_Id, InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankPath, InfoBankActive,
		SystemID = System_Id, SystemFullName, SystemActive, SystemOrder, SystemShortName, SystemBaseName, Required, HostID, InfoBankStart
	FROM dbo.SystemInfoBanksView WITH(NOEXPAND)
	WHERE System_Id = @System
		AND DistrType_Id = @DistrType
)
