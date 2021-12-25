USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemBankGet(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[SystemBankGet(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [dbo].[SystemBankGet(Internal)]
(
	-- Id системы
	@System		Int
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankPath, InfoBankActive,
		SystemID, SystemFullName, SystemActive, SystemOrder, SystemShortName, SystemBaseName, Required, HostID, InfoBankStart
	FROM dbo.SystemBanksView WITH(NOEXPAND)
	WHERE SystemId = @System
)
GO
