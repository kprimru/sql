﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IMPORT_FROM_MASTER_DAILY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[IMPORT_FROM_MASTER_DAILY]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[IMPORT_FROM_MASTER_DAILY]
AS
BEGIN
	SET NOCOUNT ON;

        DECLARE @Query          NVarChar(Max);
        DECLARE @SubhostName    VarChar(10);

        DECLARE @Distr Table
		(
		    -- HostID - из ALPHA!
			HostID	SmallInt	    NOT NULL,
			HostReg	VarChar(100)    NOT NULL,
			Distr	Int			    NOT NULL,
			Comp	TinyInt		    NOT NULL,
			Primary Key Clustered(Distr, HostID, Comp)
		);

        SET @SubhostName = Maintenance.GlobalSubhostName();


        SET @Query = 'SELECT HostID, HostReg, DistrNumber, CompNumber FROM OPENQUERY([PC275-SQL\ALPHA], ''SELECT * FROM ClientDB.dbo.SubhostDistrs@Get(NULL, ''''' + @SubhostName + ''''');'');';

        INSERT INTO @Distr(HostID, HostReg, Distr, Comp)
        EXEC (@Query);

		-- Обновляем справочник Хостов
		INSERT INTO dbo.Hosts(HostShort, HostReg, HostOrder)
		SELECT D.[HostShort], D.[HostReg], D.[HostOrder]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] AS D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [dbo].[Hosts] H
				WHERE D.[HostReg] = H.[HostReg]
			);

		UPDATE H
		SET HostShort = D.HostShort,
			HostOrder = D.HostOrder
		FROM dbo.Hosts H
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] AS D ON H.[HostReg] = D.[HostReg]
		WHERE H.HostShort != D.HostShort
			OR H.HostOrder != D.HostOrder;

		-- Обновляем справочник категорий
		INSERT INTO [dbo].[ClientTypeTable]([ClientTypeName], [ClientTypeDailyDay], [ClientTypeDay], [ClientTypePapper], [SortIndex])
		SELECT D.[ClientTypeName], D.[ClientTypeDailyDay], D.[ClientTypeDay], D.[ClientTypePapper], D.[SortIndex]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeTable] AS D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [dbo].[ClientTypeTable] H
				WHERE D.[ClientTypeName] = H.[ClientTypeName]
			);

		UPDATE H
		SET [ClientTypeDailyDay]    = D.[ClientTypeDailyDay],
		    [ClientTypeDay]         = D.[ClientTypeDay],
		    [ClientTypePapper]      = D.[ClientTypePapper],
			[SortIndex]             = D.[SortIndex]
		FROM [dbo].[ClientTypeTable] H
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeTable] AS D ON H.[ClientTypeName] = D.[ClientTypeName]
		WHERE H.[ClientTypeDailyDay] != D.[ClientTypeDailyDay]
			OR H.[ClientTypeDay] != D.[ClientTypeDay]
			OR H.[ClientTypePapper] != D.[ClientTypePapper]
			OR H.[SortIndex] != D.[SortIndex];

		-- Обновляем справочник систем
		INSERT INTO dbo.SystemTable(
			SystemShortName, SystemName, SystemBaseName, SystemNumber, HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName,
			SystemDin, SystemActive, SystemStart, SystemEnd, SystemDemo, SystemComplect, SystemReg, SystemBaseCheck
			)
		SELECT
			SystemShortName, SystemName, SystemBaseName, SystemNumber, H.HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName,
			SystemDin, SystemActive, SystemStart, SystemEnd, SystemDemo, SystemComplect, SystemReg, SystemBaseCheck
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] D
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] Z ON Z.HostId = D.HostID
		INNER JOIN dbo.Hosts H ON Z.HostReg = H.HostReg
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemTable S
				WHERE S.SystemBaseName = D.SystemBaseName
			);

		UPDATE S
		SET	SystemShortName = D.SystemShortName,
			SystemName		= D.SystemName,
			SystemNumber	= D.SystemNumber,
			HostID			= H.HostID,
			SystemRic		= D.SystemRic,
			SystemOrder		= D.SystemOrder,
			SystemVMI		= D.SystemVMI,
			SystemFullName	= D.SystemFullName,
			SystemDin		= D.SystemDin,
			SystemActive	= D.SystemActive,
			SystemStart		= D.SystemStart,
			SystemEnd		= D.SystemEnd,
			SystemDemo		= D.SystemDemo,
			SystemComplect	= D.SystemComplect,
			SystemReg		= D.SystemReg,
			SystemBaseCheck	= D.SystemBaseCheck
		FROM dbo.SystemTable S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] D ON S.SystemBaseName = D.SystemBaseName
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] Z ON Z.HostId = D.HostID
		INNER JOIN dbo.Hosts H ON Z.HostReg = H.HostReg
		WHERE S.SystemShortName		!= D.SystemShortName
			OR S.SystemName			!= D.SystemName
			OR S.SystemNumber		!= D.SystemNumber
			OR S.HostID				!= H.HostID
			OR S.SystemRic			!= D.SystemRic
			OR S.SystemOrder		!= D.SystemOrder
			OR S.SystemVMI			!= D.SystemVMI
			OR S.SystemFullName		!= D.SystemFullName
			OR S.SystemDin			!= D.SystemDin
			OR S.SystemActive		!= D.SystemActive
			OR S.SystemStart		!= D.SystemStart
			OR S.SystemEnd			!= D.SystemEnd
			OR S.SystemDemo			!= D.SystemDemo
			OR S.SystemComplect		!= D.SystemComplect
			OR S.SystemReg			!= D.SystemReg
			OR S.SystemBaseCheck	!= D.SystemBaseCheck;

		-- обновляем ИБ

		INSERT INTO dbo.InfoBankTable(InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankActive, InfoBankDaily, InfoBankActual, InfoBankStart)
		SELECT InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankActive, InfoBankDaily, InfoBankActual, InfoBankStart
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InfoBankTable I
				WHERE I.InfoBankName = D.InfoBankName
			);

		UPDATE I
		SET InfoBankShortName	= D.InfoBankShortName,
			InfoBankFullName	= D.InfoBankFullName,
			InfoBankOrder		= D.InfoBankOrder,
			InfoBankActive		= D.InfoBankActive,
			InfoBankDaily		= D.InfoBankDaily,
			InfoBankActual		= D.InfoBankActual,
			InfoBankStart		= D.InfoBankStart
		FROM dbo.InfoBankTable I
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] D ON I.InfoBankName = D.InfoBankName
		WHERE I.InfoBankShortName	!= D.InfoBankShortName
			OR I.InfoBankFullName	!= D.InfoBankFullName
			OR I.InfoBankOrder		!= D.InfoBankOrder
			OR I.InfoBankActive		!= D.InfoBankActive
			OR I.InfoBankDaily		!= D.InfoBankDaily
			OR I.InfoBankActual		!= D.InfoBankActual
			OR I.InfoBankStart		!= D.InfoBankStart;

		-- Обновляем состав систем
		/*
		UPDATE SB
		SET [Required] = D.[Required]
		FROM dbo.SystemBankTable SB
		INNER JOIN dbo.SystemTable S ON S.SystemID = SB.SystemID
		INNER JOIN dbo.InfoBankTable I ON I.InfoBankID = SB.InfoBankID
		INNER JOIN @SystemBanks D ON D.System = S.SystemBaseName AND D.InfoBank = I.InfoBankName
		WHERE SB.[Required] != D.[Required];

		DELETE SB
		FROM dbo.SystemBankTable SB
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @SystemBanks D
				INNER JOIN dbo.SystemTable S ON S.SystemBaseName = D.System
				INNER JOIN dbo.InfoBankTable I ON I.InfoBankName = D.InfoBank
				WHERE S.SystemID = SB.SystemID AND I.InfoBankID = SB.InfoBankID
			);

		INSERT INTO dbo.SystemBankTable(SystemID, InfoBankID, [Required])
		SELECT S.SystemID, I.InfoBankID, D.[Required]
		FROM @SystemBanks D
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName = D.System
		INNER JOIN dbo.InfoBankTable I ON I.InfoBankName = D.InfoBank
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemBankTable SB
				WHERE S.SystemID = SB.SystemID AND I.InfoBankID = SB.InfoBankID
			);
		*/


		-- обновляем справочник типов систем

		UPDATE S
		SET SST_NAME = D.SST_NAME,
			SST_SHORT = D.SST_SHORT,
			SST_NOTE = D.SST_NOTE
		FROM Din.SystemType S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[SystemType] D ON S.SST_REG = D.SST_REG
		WHERE S.SST_NAME != D.SST_NAME
			OR S.SST_SHORT != D.SST_SHORT
			OR S.SST_NOTE != D.SST_NOTE;

		INSERT INTO Din.SystemType(SST_NAME, SST_SHORT, SST_NOTE, SST_REG)
		SELECT D.SST_NAME, D.SST_SHORT, D.SST_NOTE, D.SST_REG
		FROM [PC275-SQL\ALPHA].[ClientDB].[Din].[SystemType] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Din.SystemType S
				WHERE S.SST_REG = D.SST_REG
			);

		-- статусы клиента
		UPDATE S
		SET [ServiceStatusName]		= D.[ServiceStatusName],
			[ServiceStatusIndex]	= D.[ServiceStatusIndex],
			[ServiceStatusReg]		= D.[ServiceStatusReg],
			[ServiceDefault]		= D.[ServiceDefault]
		FROM dbo.ServiceStatusTable S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ServiceStatusTable] D ON S.[ServiceCode] = D.[ServiceCode]
		WHERE S.[ServiceStatusName] != D.[ServiceStatusName]
			OR S.[ServiceStatusIndex] != D.[ServiceStatusIndex]
			OR S.[ServiceStatusReg] != D.[ServiceStatusReg]
			OR S.[ServiceDefault] != D.[ServiceDefault];

		INSERT INTO dbo.ServiceStatusTable([ServiceStatusName], [ServiceStatusIndex], [ServiceStatusReg], [ServiceDefault], [ServiceCode])
		SELECT D.[ServiceStatusName], D.[ServiceStatusIndex], D.[ServiceStatusReg], D.[ServiceDefault], D.[ServiceCode]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ServiceStatusTable] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ServiceStatusTable S
				WHERE S.[ServiceCode] = D.[ServiceCode]
			);

		-- бизнес-справочник типов сети
		UPDATE N
		SET DistrTypeName		= D.DistrTypeName,
			DistrTypeOrder		= D.DistrTypeOrder,
			DistrTypeFull		= D.DistrTypeFull,
			DistrTypeBaseCheck	= D.DistrTypeBaseCheck
		FROM dbo.DistrTypeTable N
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] D ON N.DistrTypeCode = D.DistrTypeCode
		WHERE N.DistrTypeName != D.DistrTypeName
			OR N.DistrTypeFull != D.DistrTypeFull
			OR N.DistrTypeOrder != D.DistrTypeOrder
			OR N.DistrTypeBaseCheck != D.DistrTypeBaseCheck;

		INSERT INTO dbo.DistrTypeTable(DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeBaseCheck, DistrTypeCode)
		SELECT DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeBaseCheck, DistrTypeCode
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DistrTypeTable N
				WHERE N.DistrTypeCode = D.DistrTypeCode
			);

		-- Справочник типов сети
		UPDATE N
		SET NT_NAME = D.NT_NAME,
			NT_SHORT = D.NT_SHORT,
			NT_NOTE = D.NT_NOTE,
			NT_TECH_USR = D.NT_TECH_USR
		FROM Din.NetType N
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] D ON N.NT_NET = D.NT_NET AND N.NT_TECH = D.NT_TECH AND N.NT_ODON = D.NT_ODON AND N.NT_ODOFF = D.NT_ODOFF
		WHERE N.NT_NAME != D.NT_NAME
			OR N.NT_SHORT != D.NT_SHORT
			OR N.NT_NOTE != D.NT_NOTE
			OR IsNull(N.NT_TECH_USR, '') != IsNull(D.NT_TECH_USR, '');

		INSERT INTO Din.NetType(NT_NAME, NT_NOTE, NT_NET, NT_TECH, NT_SHORT, NT_TECH_USR, NT_ODON, NT_ODOFF)
		SELECT NT_NAME, NT_NOTE, NT_NET, NT_TECH, NT_SHORT, NT_TECH_USR, NT_ODON, NT_ODOFF
		FROM [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Din.NetType N
				WHERE N.NT_NET = D.NT_NET AND N.NT_TECH = D.NT_TECH AND N.NT_ODON = D.NT_ODON AND N.NT_ODOFF = D.NT_ODOFF
			);

		-- обновляем справочник статусов дистрибутива
		UPDATE S
		SET DS_NAME		= D.DS_NAME,
			DS_INDEX	= D.DS_INDEX
		FROM dbo.DistrStatus S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrStatus] D ON S.DS_REG = D.DS_REG
		WHERE S.DS_NAME != D.DS_NAME
			OR S.DS_INDEX != D.DS_INDEX;

		INSERT INTO dbo.DistrStatus(DS_NAME, DS_INDEX, DS_REG)
		SELECT D.DS_NAME, D.DS_INDEX, D.DS_REG
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrStatus] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DistrStatus S
				WHERE S.DS_REG = D.DS_REG
			);

		-- Обновляем справочник правил категорий
		INSERT INTO [dbo].[ClientTypeRules]([System_Id], [DistrType_Id], [ClientType_Id])
		SELECT HS.[SystemID], HD.[DistrTypeID], HC.[ClientTypeID]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeRules] AS D
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS DS ON DS.[SystemID] = D.[System_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] AS DD ON DD.[DistrTypeID] = D.[DistrType_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeTable] AS DC ON DC.[ClientTypeID] = D.[ClientType_Id]
		INNER JOIN [dbo].[ClientTypeTable] AS HC ON HC.[ClientTypeName] = DC.[ClientTypeName]
		INNER JOIN [dbo].[SystemTable] AS HS ON HS.[SystemBaseName] = DS.[SystemBaseName]
		INNER JOIN [dbo].[DistrTypeTable] AS HD ON HD.[DistrTypeCode] = DD.[DistrTypeCode]
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [dbo].[ClientTypeRules] AS H
		        WHERE H.[System_Id] = HS.[SystemID]
		            AND H.[DistrType_Id] = HD.[DistrTypeID]
			);

		UPDATE H
		SET [ClientType_Id]    = HC.[ClientTypeID]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeRules] AS D
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS DS ON DS.[SystemID] = D.[System_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] AS DD ON DD.[DistrTypeID] = D.[DistrType_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientTypeTable] AS DC ON DC.[ClientTypeID] = D.[ClientType_Id]
		INNER JOIN [dbo].[ClientTypeTable] AS HC ON HC.[ClientTypeName] = DC.[ClientTypeName]
		INNER JOIN [dbo].[SystemTable] AS HS ON HS.[SystemBaseName] = DS.[SystemBaseName]
		INNER JOIN [dbo].[DistrTypeTable] AS HD ON HD.[DistrTypeCode] = DD.[DistrTypeCode]
		INNER JOIN [dbo].[ClientTypeRules] AS H ON D.[System_Id] = HS.[SystemID] AND D.[DistrType_Id] = HD.[DistrTypeID]
		WHERE H.[ClientType_Id] != HC.[ClientTypeID];

		-- обновляем справочник типов соответствия USR

		UPDATE S
		SET ComplianceTypeShortName	= D.ComplianceTypeShortName,
			ComplianceTypeOrder		= D.ComplianceTypeOrder
		FROM dbo.ComplianceTypeTable S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ComplianceTypeTable] D ON S.ComplianceTypeName = D.ComplianceTypeName
		WHERE S.ComplianceTypeShortName != D.ComplianceTypeShortName
			OR S.ComplianceTypeOrder != D.ComplianceTypeOrder;

		INSERT INTO dbo.ComplianceTypeTable(ComplianceTypeName, ComplianceTypeShortName, ComplianceTypeOrder)
		SELECT D.ComplianceTypeName, D.ComplianceTypeShortName, D.ComplianceTypeOrder
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ComplianceTypeTable] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ComplianceTypeTable S
				WHERE S.ComplianceTypeName = D.ComplianceTypeName
			);

		-- обновляем справочник типов формирования файлов USR

		UPDATE S
		SET USRFileKindShortName	= D.USRFileKindShortName,
			USRFileKindShort		= D.USRFileKindShort
		FROM dbo.USRFileKindTable S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[USRFileKindTable] D ON S.USRFileKindName = D.USRFileKindName
		WHERE S.USRFileKindShortName != D.USRFileKindShortName
			OR S.USRFileKindShort != D.USRFileKindShort;

		INSERT INTO dbo.USRFileKindTable(USRFileKindName, USRFileKindShortName, USRFileKindShort)
		SELECT D.USRFileKindName, D.USRFileKindShortName, D.USRFileKindShort
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[USRFileKindTable] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.USRFileKindTable S
				WHERE S.USRFileKindName = D.USRFileKindName
			);

		-- обновляем справочник типов сотрудников

		UPDATE S
		SET CPT_NAME		= D.CPT_NAME,
			CPT_SHORT		= D.CPT_SHORT,
			CPT_REQUIRED	= D.CPT_REQUIRED,
			CPT_ORDER		= D.CPT_ORDER
		FROM dbo.ClientPersonalType S
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientPersonalType] D ON S.CPT_PSEDO = D.CPT_PSEDO
		WHERE S.CPT_NAME != D.CPT_NAME
			OR S.CPT_SHORT != D.CPT_SHORT
			OR S.CPT_REQUIRED != D.CPT_REQUIRED
			OR S.CPT_ORDER != D.CPT_ORDER;

		INSERT INTO dbo.ClientPersonalType(CPT_NAME, CPT_SHORT, CPT_PSEDO, CPT_REQUIRED, CPT_ORDER)
		SELECT D.CPT_NAME, D.CPT_SHORT, D.CPT_PSEDO, D.CPT_REQUIRED, D.CPT_ORDER
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientPersonalType] D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientPersonalType S
				WHERE S.CPT_PSEDO = D.CPT_PSEDO
			);

		-- обновляем количество документов

		INSERT INTO dbo.StatisticTable(StatisticDate, InfoBankID, Docs)
		SELECT A.StatisticDate, I.InfoBankID, A.Docs
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[StatisticTable] AS A
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] AS AI ON A.InfoBankID = AI.InfoBankID
		INNER JOIN dbo.InfoBankTable I ON I.InfoBankName = AI.InfoBankName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.StatisticTable Z
				WHERE Z.InfoBankID = I.InfoBankID
					AND Z.StatisticDate = A.StatisticDate
			)

		DELETE FROM [dbo].[Weight];

		INSERT INTO [dbo].[Weight]([Date], [System_Id], [SystemType_Id], [NetType_Id], [Weight])
		SELECT W.[Date], DS.[SystemID], DT.[SST_ID], DN.[NT_ID], W.[Weight]
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[Weight] AS W
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS S ON S.[SystemID] = W.[System_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[SystemType] AS T ON T.[SST_ID] = W.[SystemType_Id]
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] AS N ON N.[NT_ID] = W.[NetType_Id]
		INNER JOIN [dbo].[SystemTable] AS DS ON DS.[SYstemBaseName] = S.[SystemBaseName]
		INNER JOIN [Din].[SystemType] AS DT ON DT.[SST_REG] = T.[SST_REG]
		INNER JOIN [Din].[NetType] AS DN ON DN.[NT_NET] = N.[NT_NET] AND DN.[NT_TECH] = N.[NT_TECH] AND DN.[NT_ODON] = N.[NT_ODON] AND DN.[NT_ODOFF] = N.[NT_ODOFF]

		TRUNCATE TABLE [Price].[DistrType:Coef];

		INSERT INTO [Price].[DistrType:Coef]([DistrType_Id], [Date], [Coef], [Round])
		SELECT N.[DistrTypeID], AC.[Date], AC.[Coef], AC.[Round]
		FROM [PC275-SQL\ALPHA].[ClientDB].[Price].[DistrType:Coef]		AS AC
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable]	AS D ON AC.[DistrType_Id] = D.[DistrTypeID]
		INNER JOIN [dbo].[DistrTypeTable]								AS N ON N.[DistrTypeCode] = D.[DistrTypeCode];

		TRUNCATE TABLE [Price].[SystemType:Coef];

		INSERT INTO [Price].[SystemType:Coef]([SystemType_Id], [Date], [Coef], [Round])
		SELECT N.[SystemTypeID], AC.[Date], AC.[Coef], AC.[Round]
		FROM [PC275-SQL\ALPHA].[ClientDB].[Price].[SystemType:Coef]		AS AC
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTypeTable]	AS D ON AC.[SystemType_Id] = D.[SystemTypeID]
		INNER JOIN [dbo].[SystemTypeTable]								AS N ON N.[SystemTypeName] = D.[SystemTypeName];

	    DELETE SB
		FROM dbo.SystemsBanks SB
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemsBanks] AS ASB
				INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS AST ON ASB.System_Id = AST.SystemID
				INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] AS ADT ON ASB.DistrType_Id = ADT.DistrTypeID
				INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] AS AIB ON ASB.InfoBank_Id = AIB.InfoBankID
				INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] AS ANT ON ADT.DistrTypeID = ANT.NT_ID_MASTER
				INNER JOIN Din.NetType AS NT ON     ANT.NT_NET = NT.NT_NET
									            AND ANT.NT_TECH =NT.NT_TECH
									            AND ANT.NT_ODON = NT.NT_ODON
									            AND ANT.NT_ODOFF = NT.NT_ODOFF
				INNER JOIN dbo.DistrTypeTable DT ON DT.DistrTypeID = NT.NT_ID_MASTER
				INNER JOIN dbo.InfoBankTable AS IB ON IB.InfoBankName = AIB.InfoBankName
				INNER JOIN dbo.SystemTable AS ST ON ST.SystemBaseName = AST.SystemBaseName
				WHERE ST.[SystemID] = SB.[System_Id]
					AND DT.[DistrTypeID] = SB.[DistrType_Id]
					AND IB.[InfoBankID] = SB.[InfoBank_Id]
			);

		INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, Required, Start)
		SELECT DISTINCT ST.[SystemID], DT.[DistrTypeID], IB.[InfoBankID], Required, Start
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemsBanks] AS ASB
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS AST ON ASB.System_Id = AST.SystemID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] AS ADT ON ASB.DistrType_Id = ADT.DistrTypeID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] AS AIB ON ASB.InfoBank_Id = AIB.InfoBankID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] AS ANT ON ADT.DistrTypeID = ANT.NT_ID_MASTER
		INNER JOIN Din.NetType AS NT ON     ANT.NT_NET = NT.NT_NET
							            AND ANT.NT_TECH =NT.NT_TECH
							            AND ANT.NT_ODON = NT.NT_ODON
							            AND ANT.NT_ODOFF = NT.NT_ODOFF
		INNER JOIN dbo.DistrTypeTable DT ON DT.DistrTypeID = NT.NT_ID_MASTER
		INNER JOIN dbo.InfoBankTable AS IB ON IB.InfoBankName = AIB.InfoBankName
		INNER JOIN dbo.SystemTable AS ST ON ST.SystemBaseName = AST.SystemBaseName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemsBanks SB
				WHERE ST.[SystemID] = SB.[System_Id]
					AND DT.[DistrTypeID] = SB.[DistrType_Id]
					AND IB.[InfoBankID] = SB.[InfoBank_Id]
			);

		UPDATE SB
		SET Required	= ASB.Required,
			Start		= ASB.Start
		FROM dbo.SystemsBanks SB
		INNER JOIN dbo.DistrTypeTable AS DT ON DT.[DistrTypeID] = SB.[DistrType_Id]
		INNER JOIN dbo.InfoBankTable AS IB ON IB.[InfoBankID] = SB.[InfoBank_Id]
		INNER JOIN dbo.SystemTable AS ST ON ST.[SystemID] = SB.[System_Id]
		INNER JOIN Din.NetType AS NT ON DT.DistrTypeID = NT.NT_ID_MASTER
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Din].[NetType] AS ANT ON     ANT.NT_NET = NT.NT_NET
							                                                AND ANT.NT_TECH =NT.NT_TECH
							                                                AND ANT.NT_ODON = NT.NT_ODON
							                                                AND ANT.NT_ODOFF = NT.NT_ODOFF
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[DistrTypeTable] AS ADT ON ADT.DistrTypeID = ANT.NT_ID_MASTER
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[InfoBankTable] AS AIB ON IB.InfoBankName = AIB.InfoBankName
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS AST ON ST.SystemBaseName = AST.SystemBaseName
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemsBanks] AS ASB ON ASB.System_Id = AST.SystemID
		                                                                    AND ASB.InfoBank_Id = AIB.InfoBankID
		                                                                    AND ASB.DistrType_Id = ADT.DistrTypeID
		WHERE ASB.Required != SB.Required
			OR IsNull(SB.Start, '20000101') != IsNull(ASB.Start, '20000101');


	    -- Обновляем прейкурант
		TRUNCATE TABLE [Price].[System:Price];

		INSERT INTO [Price].[System:Price]([System_Id], [Date], [Price])
		SELECT S.[SystemID], P.[Date], P.[Price]
		FROM [PC275-SQL\ALPHA].[ClientDB].[Price].[System:Price]	AS P
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS SS	ON SS.[SystemID] = P.[System_Id]
		INNER JOIN [dbo].[SystemTable]								AS S	ON S.[SystemBaseName] = SS.[SystemBaseName];

		/*
		INSERT INTO @NamedSets
		SELECT
			C.value('@SetId[1]',				'UniqueIdentifier'),
			C.value('@RefName[1]',				'VarChar(256)'),
			C.value('@SetName[1]',				'VarCHar(256)')
		FROM @Data.nodes('/DATA[1]/NAMED_SETS[1]/SERVCICE_STATUS_NAMED_SETS[1]/SET') N(C);

		INSERT INTO @NamedSetsItems
		SELECT
			C.value('@SetId[1]',				'UniqueIdentifier'),
			R.[Code]
		FROM @Data.nodes('/DATA[1]/NAMED_SETS[1]/SERVCICE_STATUS_NAMED_SETS[1]/SET') N(C)
		CROSS APPLY
		(
			SELECT [Code] = R.value('@Code[1]',				'VarChar(200)')
			FROM C.nodes('./ITEMS/ITEM') I(R)
		) R

		INSERT INTO dbo.NamedSets
		SELECT *
		FROM @NamedSets S
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.NamedSets Z
				WHERE S.SetId = Z.SetId
			);

		DELETE Z FROM dbo.NamedSets Z
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @NamedSets S
				WHERE S.SetId = Z.SetId
			);

		UPDATE S
		SET RefName = Z.RefName,
			SetName = Z.SetName
		FROM dbo.NamedSets S
		INNER JOIN @NamedSets Z ON S.SetId = Z.SetId;

		-- ToDo Как сделать универсально, а не для каждой таблицы?
		INSERT INTO dbo.NamedSetsItems(SetId, SetItem)
		SELECT S.SetId, C.ServiceStatusId
		FROM @NamedSets S
		INNER JOIN @NamedSetsItems I ON S.SetId = I.SetId
		INNER JOIN dbo.ServiceStatusTable C ON C.ServiceCode = I.ItemCode
		WHERE S.RefName = 'dbo.ServiceStatusTable'
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.NamedSetsItems Z
					WHERE Z.SetId = S.SetId
						AND Z.SetItem = C.ServiceStatusId
				);

		DELETE Z FROM dbo.NamedSetsItems Z
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @NamedSets S
				INNER JOIN @NamedSetsItems I ON S.SetId = I.SetId
				INNER JOIN dbo.ServiceStatusTable C ON C.ServiceCode = I.ItemCode
				WHERE Z.SetId = S.SetId
					AND Z.SetItem = C.ServiceStatusId
			);
			*/

		UPDATE SN SET
		    NOTE        = SNA.NOTE,
		    NOTE_WTITLE = SNA.NOTE_WTITLE
		FROM dbo.SystemNote AS SN
		INNER JOIN dbo.SystemTable AS S ON SN.ID_SYSTEM = S.SystemID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS SA ON SA.SystemBaseName = S.SystemBaseName
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemNote] AS SNA ON SNA.ID_SYSTEM = SA.SystemID
		WHERE SN.NOTE != SNA.NOTE
		    OR SN.NOTE_WTITLE != SNA.NOTE_WTITLE;


		INSERT INTO dbo.ControlDocument(DATE, RIC, SYS_NUM, DISTr, COMP, IB, IB_NUM, DOC_NAME)
		SELECT DATE, RIC, SYS_NUM, CA.DISTR, CA.COMP, IB, IB_NUM, DOC_NAME
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ControlDocument] AS CA
		WHERE EXISTS
		    (
		        SELECT *
		        FROM @Distr AS D
		        INNER JOIN dbo.Hosts AS H ON D.HostReg = H.HostReg
		        INNER JOIN dbo.SystemTable AS S ON S.HostID = H.HostID
		        WHERE CA.SYS_NUM = S.SystemNumber
		            AND CA.DISTR = D.Distr
		            AND CA.COMP = D.Comp
		    )
		    AND NOT EXISTS
		    (
		        SELECT *
		        FROM dbo.ControlDocument AS C
		        WHERE C.SYS_NUM = CA.SYS_NUM
		            AND C.DISTR = CA.DISTR
		            AND C.COMP = CA.COMP
		            AND C.DATE = CA.DATE
		            AND C.RIC = CA.RIC
		            AND C.IB = CA.IB
		            AND C.IB_NUM = CA.IB_NUM
		            AND C.DOC_NAME = CA.DOC_NAME
		    )
		OPTION(FORCE ORDER);

		--ToDo переделать на MERGE
		DELETE FROM dbo.OnlineActivity;

		INSERT INTO dbo.OnlineActivity(ID_WEEK, ID_HOST, DISTR, COMP, LGN, ACTIVITY, LOGIN_CNT, SESSION_TIME)
		SELECT P.ID, H.HostID, CA.DISTR, CA.COMP, CA.LGN, CA.ACTIVITY, CA.LOGIN_CNT, CA.SESSION_TIME
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[OnlineActivity] AS CA
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Common].[Period] AS PA ON PA.ID = CA.ID_WEEK
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] AS HA ON HA.HostID = CA.ID_HOST
		INNER JOIN dbo.Hosts AS H ON H.HostReg = HA.HostReg
		INNER JOIN Common.Period AS P ON P.START = PA.START AND P.TYPE = PA.TYPE
		WHERE EXISTS
		    (
		        SELECT *
		        FROM @Distr AS D
		        WHERE HA.HostID = D.HostID
		            AND CA.DISTR = D.Distr
		            AND CA.COMP = D.Comp
		    )
		    AND NOT EXISTS
		    (
		        SELECT *
		        FROM [dbo].[OnlineActivity] AS C
		        WHERE C.ID_HOST = H.HostID
		            AND C.DISTR = CA.DISTR
		            AND C.COMP = CA.COMP
		            AND C.LGN = CA.LGN
		            AND C.ID_WEEK = P.ID
		    )
		OPTION(FORCE ORDER);

		INSERT INTO dbo.ClientStatDetail([UpDate], WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [0Enter], [1Enter], [2Enter], [3Enter], SessionTimeSum, SessionTimeAVG)
		SELECT CA.[UpDate], P.ID, H.HostId, CA.Distr, CA.Comp, CA.Net, CA.UserCount, CA.EnterSum, CA.[0Enter], CA.[1Enter], CA.[2Enter], CA.[3Enter], CA.SessionTimeSum, CA.SessionTimeAVG
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientStatDetail] AS CA
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[Common].[Period] AS PA ON PA.ID = CA.WeekID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[Hosts] AS HA ON HA.HostID = CA.HostID
		INNER JOIN dbo.Hosts AS H ON H.HostReg = HA.HostReg
		INNER JOIN Common.Period AS P ON P.START = PA.START AND P.TYPE = PA.TYPE
		WHERE EXISTS
		    (
		        SELECT *
		        FROM @Distr AS D
		        WHERE HA.HostID = D.HostID
		            AND CA.DISTR = D.Distr
		            AND CA.COMP = D.Comp
		    )
		    AND NOT EXISTS
		    (
		        SELECT *
		        FROM [dbo].[ClientStatDetail] AS C
		        WHERE C.HostID = H.HostID
		            AND C.DISTR = CA.DISTR
		            AND C.COMP = CA.COMP
		            AND C.WeekId = P.ID
		    )
		OPTION(FORCE ORDER);
END

GO
