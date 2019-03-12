USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [dbo].[SystemBankGet]
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
		InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankPath, InfoBankActive,
		SystemID, SystemFullName, SystemActive, SystemOrder, SystemShortName, SystemBaseName, Required, HostID, InfoBankStart
	FROM dbo.[SystemBankGet(Internal)](@System)
	WHERE NOT
		(
			@DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 13)
			OR
			SystemBaseName = 'SKBO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SKUO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SBOO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SKJP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SKUP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SBOP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
			OR
			SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		)
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKBO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'BUHL'
	
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKUO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'MBP'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SBOO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'BUD'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKJP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'JURP'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKUP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'BVP'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SBOP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'BOVP'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'MBP'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'MED'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		SB.SystemID, SB.SystemFullName, SB.SystemActive, SB.SystemOrder, SB.SystemShortName, SB.SystemBaseName, SB.Required, SB.HostID, SB.InfoBankStart
	FROM dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE SB.SystemID = @System AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 13)
		AND B.SystemBaseName = 'KRF'
)
