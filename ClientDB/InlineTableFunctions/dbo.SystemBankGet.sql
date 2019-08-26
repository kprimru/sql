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
			OR
			SystemBaseName = 'SKBP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKBO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKBB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKJE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKJP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKJO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKJB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKUE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKUP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKUO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKUB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SBOE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SBOP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SBOO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SBOB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SPK-V' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SPK-IV' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SPK-III' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SPK-II' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SPK-I' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKBEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKJEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKUEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SBOEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKZB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
			OR
			SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
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
	/*
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'MBP'
	*/
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, SB.Required, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.SystemTable B
	CROSS APPLY dbo.[SystemBankGet(Internal)](B.SystemId) SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND B.SystemBaseName = 'MBP'
		AND SB.InfoBankName != 'ROS'
		
	UNION ALL
	
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 11)
		AND SB.InfoBankName = 'RZB'
		
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
		
	UNION ALL
	
	/*
	!!!ВНИМАНИЕ!!! КОСТЫЛИ ДЛЯ СМАРТ-КОМЛПЕКТОВ!!!
	*/
	
	-- Б(0)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKBO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('BCN', 'BDV', 'BMS', 'BPV', 'BRB', 'BSK', 'BSZ', 'BUR', 'BVS', 'BVV', 'BZS', 'DOF', 'KRS', 'PBI', 'PKV', 'PPN', 'PPS', 'QSA', 'ROS')
		
	UNION ALL
		
	-- Б(+1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKBP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('BCN', 'BDV', 'BMS', 'BPV', 'BRB', 'BSK', 'BSZ', 'BUR', 'BVS', 'BVV', 'BZS', 'DOF', 'KRS', 'PBI', 'PKV', 'PPN', 'PPS', 'QUEST', 'RGSS', 'RZR', 'RLAW020', 'REXP020')
	
	
	UNION ALL
	
	-- Б(-1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKBB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('DOCS', 'PBI', 'QSA', 'PPN', 'PPS', 'KRS', 'RBAS020', 'DOF')
	
	UNION ALL	

	-- Ю(0)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKJO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZR', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'ADV', 'RBAS020')

		
	UNION ALL
	
	-- Ю(+1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKJP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'ADV', 'RLAW020', 'RAPS005', 'SODV')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?
	
	UNION ALL
	
	-- Ю(+2)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKJE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?

	UNION ALL

	-- Ю(-1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKJB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('ROS', 'ARB', 'CMBB', 'CJIB', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RBAS020')

	UNION ALL

	-- У(0)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKUO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZR', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'SIP', 'PPVS', 'RGSS', 'ADV', 'RBAS020', 'PBI', 'QSA', 'PPN', 'PKV', 'PPS', 'BVV', 'BVS', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN')

	UNION ALL
	
	-- У(+1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKUP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'ADV', 'RLAW020', 'RAPS005', 'SODV', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS', 'BVV', 'BVS', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN', 'RGSS')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?
		
	UNION ALL
	
	-- У(+2)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKUE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?
		
	UNION ALL
	
	-- У(-1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKZB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('ROS', 'ARB', 'CMBB', 'CJIB', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'SIP', 'PPVS', 'RGSS', 'RBAS020', 'PBIB', 'QSA', 'PPN', 'PPS')

	UNION ALL

	-- З(0)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKZO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZR', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'SIP', 'PPVS', 'RGSS', 'ADV', 'RBAS020', 'PBI', 'QSA', 'PPN', 'PKV', 'PPS', 'BVV', 'BVS', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN', 'MED')

	UNION ALL

	-- З(-1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKUB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('ROS', 'ARB', 'CMBB', 'CJIB', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RBAS020', 'PBIB', 'QSA', 'PPN', 'PPS', 'MED')

	UNION ALL
	
	-- БО(0)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SBOO' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZB', 'EPB', 'PKV', 'ARB', 'PKG', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'QSBO', 'KRBO', 'PBUN', 'PKBO', 'RGSS', 'CJI', 'CMB', 'ADV', 'RLBR020', 'PBI', 'QUEST', 'PPN', 'PKV', 'PPS', 'BRB', 'BVV', 'BVS', 'BDV', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN')

	UNION ALL
	
	-- БО(+1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SBOP' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'EPB', 'PKV', 'ARB', 'PKG', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'QSBO', 'KRBO', 'PBUN', 'PKBO', 'RGSS', 'CJI', 'CMB', 'ADV', 'RLAW020', 'CMB', 'CJI', 'CMT', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'PPVS', 'RAPS005', 'SODV')

	UNION ALL
	
	-- БО(+2)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SBOE' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'EPB', 'PKV', 'ARB', 'PKG', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'QSBO', 'KRBO', 'PBUN', 'PKBO', 'RGSS', 'CJI', 'CMB', 'ADV', 'RLAW020', 'CMB', 'CJI', 'CMT', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'PPVS', 'RAPS005', 'SODV', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN')

	UNION ALL
	
	-- БО(-1)
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SBOB' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZB', 'PKG', 'PSG', 'DOF', 'QSOV', 'PPVS', 'QSBO', 'KRBO', 'PBUN', 'PKBO', 'RGSS', 'RLBR020', 'PBI', 'QUEST', 'PPN', 'PKV', 'PPS', 'BRB', 'BVV', 'BVS', 'BDV', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN')

	UNION ALL
	
	-- СПК1
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SPK-I' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?
		
	UNION ALL
	
	-- СПК2
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SPK-II' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS', 'PAP', 'PSR')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?

	UNION ALL
	
	-- СПК3
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SPK-III' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS', 'PAP', 'PSR', 'PAS', 'EXP', 'ESU', 'INT')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?

	UNION ALL

	-- СПК4
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SPK-IV' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS', 'PAP', 'PSR', 'PAS', 'EXP', 'ESU', 'INT', 'STR', 'MED', 'OTN')
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?
		
	UNION ALL
	
	-- СПК5
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SPK-V' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('LAW', 'ARB', 'CMB', 'CJI', 'PKS', 'PSP', 'PDR', 'PKP', 'PKG', 'PGU', 'PTS', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RGSS', 'RLAW020', 'PRJ', 'PNPA', 'SVV', 'SVS', 'SDV', 'SZS', 'SMS', 'SPV', 'SSZ', 'SSK', 'SUR', 'SCN', 'RAPS001', 'RAPS002', 'RAPS003', 'RAPS004', 'RAPS005', 'RAPS006', 'RAPS007', 'RAPS008', 'MAPS', 'RAPS011', 'RAPS012', 'RAPS013', 'RAPS014', 'RAPS015', 'RAPS016', 'RAPS017', 'RAPS018', 'RAPS019', 'RAPS020', 'RAPS021', 'SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN', 'PBI', 'FIN', 'PPN', 'PKV', 'PPS', 'KRS', 'PAP', 'PSR', 'PAS', 'EXP', 'ESU', 'INT', 'STR', 'MED', 'OTN')
		-- добавляем остальные кроме свРег. СПИСОК НАДО!!!!
		--•	Добавлен массив обзоров «Важнейшая практика по статье» что это?

	UNION ALL
	
	-- СКБЭМ
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKBEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZR', 'PBIB', 'FIN', 'BRB', 'BVV', 'BVS', 'BDV', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN', 'RLAW020', 'RGSS')
	
	UNION ALL
	
	-- СКЮЭМ
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKJEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('ROS', 'ARB', 'CMBB', 'CJIB', 'PDR', 'PKP', 'PKG', 'PGU', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RBAS020')

	UNION ALL
	
	-- СКУЭМ
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SKUEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('ROS', 'ARB', 'CMBB', 'CJIB', 'PDR', 'PKP', 'PKG', 'PGU', 'PSG', 'DOF', 'QSOV', 'SIP', 'PPVS', 'RBAS020', 'RZR', 'PBIB', 'FIN', 'BRB', 'BVV', 'BVS', 'BDV', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN', 'RLAW020', 'RGSS')

	UNION ALL
	
	-- СБОЭМ
	SELECT
		SB.InfoBankID, SB.InfoBankName, SB.InfoBankShortName, SB.InfoBankFullName, SB.InfoBankOrder, SB.InfoBankPath, SB.InfoBankActive,
		S.SystemID, S.SystemFullName, S.SystemActive, S.SystemOrder, S.SystemShortName, S.SystemBaseName, 1, S.HostID, SB.InfoBankStart
	FROM dbo.SystemTable S
	CROSS JOIN dbo.InfoBankTable SB
	WHERE S.SystemID = @System 
		AND S.SystemBaseName = 'SBOEM' AND @DistrType IN (SELECT NT_ID_MASTER FROM Din.NetType WHERE NT_TECH = 1 OR NT_TECH = 0 AND NT_NET = 0)
		AND SB.InfoBankName IN ('RZB', 'QSOV', 'QSBO', 'PBUN', 'PKBO', 'RLBR020', 'PBI', 'QUEST', 'BRB', 'BVV', 'BVS', 'BDV', 'BZS', 'BMS', 'BPV', 'BSZ', 'BSK', 'BUR', 'BCN')
)
