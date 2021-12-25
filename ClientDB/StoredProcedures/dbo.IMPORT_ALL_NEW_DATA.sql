USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IMPORT_ALL_NEW_DATA]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[IMPORT_ALL_NEW_DATA]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[IMPORT_ALL_NEW_DATA]
	@InData		NVarChar(MAX),
	@OUT_DATA	NVarChar(512) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @Data Xml;
		SET @Data = CAST(@InData AS Xml);

		DECLARE @NamedSets Table
		(
			SetId		UniqueIdentifier,
			RefName		VarChar(256),
			SetName		VarCHar(256),
			Primary Key Clustered(SetId)
		);

		DECLARE @NamedSetsItems Table
		(
			SetId		UniqueIdentifier,
			ItemCode	VarChar(256),
			Primary Key Clustered (SetId, ItemCode)
		);

		DECLARE @Hosts Table
		(
			[Short]		VarChar(100),
			[Reg]		VarChar(100),
			[Order]		Int,
			Primary Key Clustered ([Reg])
		);

		DECLARE @Systems Table
		(
			[Short]		VarChar(100),
			[Name]		VarChar(200),
			[RegName]	VarChar(100),
			[Number]	Int,
			[Host]		VarChar(100),
			[Ric]		Int,
			[Order]		Int,
			[VMI]		Int,
			[FullName]	VarChar(250),
			[DinName]	VarChar(250),
			[Active]	Bit,
			[Start]		SmallDateTime,
			[End]		SmallDateTime,
			[Demo]		Bit,
			[Complect]	Bit,
			[Reg]		Bit,
			[BaseCheck]	Bit,
			Primary Key Clustered ([RegName])
		);

		DECLARE @InfoBanks Table
		(
			[Name]		VarChar(100),
			[Short]		VarChar(100),
			[Full]		VarChar(100),
			[Order]		Int,
			[Active]	Bit,
			[Daily]		Bit,
			[Actual]	Bit,
			[Start]		SmallDateTime,
			Primary Key Clustered ([Name])
		);

		DECLARE @SystemBanks Table
		(
			[System]	VarChar(100),
			[InfoBank]	VarChar(100),
			[Required]	SmallInt,
			Primary Key Clustered ([System], [InfoBank])
		);

		DECLARE @SystemBanksNew Table
		(
			[System]	SmallInt,
			[DistrType]	SmallInt,
			[InfoBank]	SmallInt,
			[Required]	Bit,
			[Start]		SmallDateTime,
			Primary Key Clustered ([System], [DistrType], [InfoBank])
		);

		DECLARE @SysType Table
		(
			[Name]		VarChar(100),
			[Short]		VarChar(100),
			[Note]		VarChar(100),
			[Reg]		VarChar(100),
			Primary Key Clustered([Reg])
		);

		DECLARE @NetType Table
		(
			[Name]		VarChar(100),
			[Short]		VarChar(100),
			[Note]		VarChar(100),
			[TechUsr]	VarChar(100),
			[NetCnt]	Int,
			[Tech]		Int,
			[Odon]		Int,
			[Odoff]		Int,
			Primary Key Clustered ([Tech], [NetCnt], [Odon], [Odoff])
		);

		DECLARE @DistrType Table
		(
			[Name]		VarChar(50),
			[Full]		VarChar(50),
			[Code]		VarChar(100),
			[BaseCheck]	Bit,
			[Order]		Int,
			Primary Key Clustered([Code])
		);

		DECLARE @ClientStatus Table
		(
			[Name]		VarChar(50),
			[Reg]		SmallInt,
			[Index]		Int,
			[Default]	Int,
			[Code]		VarChar(100),
			Primary Key Clustered([Code])
		);

		DECLARE @DistrStatus Table
		(
			[Name]		VarChar(64),
			[Reg]		TinyInt,
			[Index]		TinyInt,
			Primary Key Clustered ([Reg])
		);

		DECLARE @Compliance Table
		(
			[Name]		VarChar(50),
			[Short]		VarChar(50),
			[Order]		Int,
			Primary Key Clustered ([Name])
		);

		DECLARE @USRKind Table
		(
			[Name]		VarChar(20),
			[ShortName]	VarChar(50),
			[Short]		VarChar(100),
			Primary Key Clustered ([Name])
		);

		DECLARE @PersonalType Table
		(
			[Name]		VarChar(100),
			[Short]		VarChar(20),
			[Psedo]		VarChar(50),
			[Required]	Bit,
			[Order]		Int,
			Primary Key Clustered ([Psedo])
		);

		DECLARE @Coef Table
		(
			[ID_NET]	SmallInt			NOT NULL,
			[COEF]		Decimal(8,4)		NOT NULL,
			[RND]		SmallInt			NOT NULL,
			[START]		SmallDateTime		NOT NULL,
			[FINISH]	SmallDateTime			NULL,
			Primary Key Clustered(ID_NET, START)
		);

		INSERT INTO @Hosts
		SELECT
			V.value('@Short[1]',	'VarChar(100)'),
			V.value('@Reg[1]',		'VarChar(100)'),
			V.value('@Order[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/HOST[1]/ITEM') N(V)

		INSERT INTO @Systems
		SELECT
			V.value('@Short[1]',		'VarChar(100)'),
			V.value('@Name[1]',			'VarChar(200)'),
			V.value('@RegName[1]',		'VarChar(100)'),
			V.value('@Number[1]',		'Int'),
			V.value('@Host[1]',			'VarChar(100)'),
			V.value('@Ric[1]',			'Int'),
			V.value('@Order[1]',		'Int'),
			V.value('@VMI[1]',			'Int'),
			V.value('@Full[1]',			'VarChar(250)'),
			V.value('@Din[1]',			'VarChar(250)'),
			V.value('@Active[1]',		'Bit'),
			V.value('@Start[1]',		'SmallDateTime'),
			V.value('@End[1]',			'SmallDateTime'),
			V.value('@Demo[1]',			'Bit'),
			V.value('@Complect[1]',		'Bit'),
			V.value('@Reg[1]',			'Bit'),
			V.value('@BaseCheck[1]',	'Bit')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/SYSTEM[1]/ITEM') N(V)

		INSERT INTO @InfoBanks
		SELECT
			V.value('@Name[1]',		'VarChar(100)'),
			V.value('@Short[1]',	'VarChar(100)'),
			V.value('@Full[1]',		'VarChar(100)'),
			V.value('@Order[1]',	'Int'),
			V.value('@Active[1]',	'Bit'),
			V.value('@Daily[1]',	'Bit'),
			V.value('@Actual[1]',	'Bit'),
			V.value('@Start[1]',	'SmallDateTime')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/INFO_BANK[1]/ITEM') N(V)

		INSERT INTO @SystemBanks
		SELECT
			V.value('@System[1]',	'VarChar(100)'),
			V.value('@InfoBank[1]',	'VarChar(100)'),
			V.value('@Required[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/SYSTEM_BANK[1]/ITEM') N(V)

		INSERT INTO @SysType
		SELECT
			V.value('@Name[1]',		'VarChar(100)'),
			V.value('@Short[1]',	'VarChar(100)'),
			V.value('@Note[1]',		'VarChar(100)'),
			V.value('@Reg[1]',		'VarChar(100)')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/SYS_TYPE[1]/ITEM') N(V)

		INSERT INTO @NetType
		SELECT
			V.value('@Name[1]',		'VarChar(100)'),
			V.value('@Short[1]',	'VarChar(100)'),
			V.value('@Note[1]',		'VarChar(100)'),
			V.value('@TechUsr[1]',	'VarChar(100)'),
			V.value('@NetCnt[1]',	'Int'),
			V.value('@Tech[1]',		'Int'),
			V.value('@Odon[1]',		'Int'),
			V.value('@Odoff[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/NET[1]/ITEM') N(V)

		INSERT INTO @DistrStatus
		SELECT
			V.value('@Name[1]',		'VarChar(64)'),
			V.value('@Reg[1]',		'TinyInt'),
			V.value('@Index[1]',	'TinyInt')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/DISTR_STATUS[1]/ITEM') N(V)

		INSERT INTO @Compliance
		SELECT
			V.value('@Name[1]',		'VarChar(50)'),
			V.value('@Short[1]',	'VarChar(50)'),
			V.value('@Order[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/COMPLIANCE[1]/ITEM') N(V)

		INSERT INTO @USRKind
		SELECT
			V.value('@Name[1]',			'VarChar(20)'),
			V.value('@ShortName[1]',	'VarChar(50)'),
			V.value('@Short[1]',		'VarChar(100)')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/USR_KIND[1]/ITEM') N(V)

		INSERT INTO @PersonalType
		SELECT
			V.value('@Name[1]',		'VarChar(100)'),
			V.value('@Short[1]',	'VarChar(20)'),
			V.value('@Psedo[1]',	'VarChar(50)'),
			V.value('@Required[1]',	'Bit'),
			V.value('@Order[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/PERSONAL_TYPE[1]/ITEM') N(V)

		INSERT INTO @DistrType
		SELECT
			V.value('@Name[1]',		'VarChar(50)'),
			V.value('@Full[1]',		'VarChar(50)'),
			V.value('@Code[1]',		'VarChar(100)'),
			V.value('@BaseCheck[1]','Bit'),
			V.value('@Order[1]',	'Int')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/DISTR_TYPE[1]/ITEM') N(V)

		INSERT INTO @ClientStatus
		SELECT
			V.value('@Name[1]',		'VarChar(100)'),
			V.value('@Reg[1]',		'Int'),
			V.value('@Index[1]',	'Int'),
			V.value('@Default[1]',	'Int'),
			V.value('@Code[1]',		'VarChar(100)')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/CLIENT_STATUS[1]/ITEM') N(V)

		-- Обновляем справочник Хостов
		INSERT INTO dbo.Hosts(HostShort, HostReg, HostOrder)
		SELECT [Short], [Reg], [Order]
		FROM @Hosts D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [dbo].[Hosts] H
				WHERE D.[Reg] = H.[HostReg]
			);

		UPDATE H
		SET HostShort = Short,
			HostOrder = [Order]
		FROM dbo.Hosts H
		INNER JOIN @Hosts D	ON H.[HostReg] = D.[Reg]
		WHERE H.HostShort != D.Short
			OR H.HostOrder != D.[Order]


		-- Обновляем справочник систем
		INSERT INTO dbo.SystemTable(
			SystemShortName, SystemName, SystemBaseName, SystemNumber, HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName,
			SystemDin, SystemActive, SystemStart, SystemEnd, SystemDemo, SystemComplect, SystemReg, SystemBaseCheck
			)
		SELECT
			[Short], [Name], [RegName], [Number], H.HostID, [Ric], [Order], [VMI], [FullName],
			[DinName], [Active], [Start], [End], [Demo], [Complect], [Reg], [BaseCheck]
		FROM @Systems D
		INNER JOIN dbo.Hosts H ON D.Host = H.HostReg
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemTable S
				WHERE S.SystemBaseName = D.RegName
			);

		UPDATE S
		SET	SystemShortName = D.Short,
			SystemName		= D.Name,
			SystemNumber	= D.Number,
			HostID			= H.HostID,
			SystemRic		= D.Ric,
			SystemOrder		= D.[Order],
			SystemVMI		= D.[VMI],
			SystemFullName	= D.FullName,
			SystemDin		= D.DinName,
			SystemActive	= D.Active,
			SystemStart		= D.Start,
			SystemEnd		= D.[End],
			SystemDemo		= D.[Demo],
			SystemComplect	= D.[Complect],
			SystemReg		= D.[Reg],
			SystemBaseCheck	= D.[BaseCheck]
		FROM dbo.SystemTable S
		INNER JOIN @Systems D ON S.SystemBaseName = D.RegName
		INNER JOIN dbo.Hosts H ON D.Host = H.HostReg
		WHERE S.SystemShortName		!= D.Short
			OR S.SystemName			!= D.Name
			OR S.SystemNumber		!= D.Number
			OR S.HostID				!= H.HostID
			OR S.SystemRic			!= D.Ric
			OR S.SystemOrder		!= D.[Order]
			OR S.SystemVMI			!= D.[VMI]
			OR S.SystemFullName		!= D.FullName
			OR S.SystemDin			!= D.DinName
			OR S.SystemActive		!= D.Active
			OR S.SystemStart		!= D.Start
			OR S.SystemEnd			!= D.[End]
			OR S.SystemDemo			!= D.[Demo]
			OR S.SystemComplect		!= D.[Complect]
			OR S.SystemReg			!= D.[Reg]
			OR S.SystemBaseCheck	!= D.[BaseCheck];

		-- обновляем ИБ

		INSERT INTO dbo.InfoBankTable(InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankActive, InfoBankDaily, InfoBankActual, InfoBankStart)
		SELECT [Name], [Short], [Full], [Order], [Active], [Daily], [Actual], [Start]
		FROM @InfoBanks D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InfoBankTable I
				WHERE I.InfoBankName = D.Name
			);

		UPDATE I
		SET InfoBankShortName	= D.[Short],
			InfoBankFullName	= D.[Full],
			InfoBankOrder		= D.[Order],
			InfoBankActive		= D.Active,
			InfoBankDaily		= D.Daily,
			InfoBankActual		= D.Actual,
			InfoBankStart		= D.Start
		FROM dbo.InfoBankTable I
		INNER JOIN @InfoBanks D ON I.InfoBankName = D.Name
		WHERE I.InfoBankShortName	!= D.[Short]
			OR I.InfoBankFullName	!= D.[Full]
			OR I.InfoBankOrder		!= D.[Order]
			OR I.InfoBankActive		!= D.Active
			OR I.InfoBankDaily		!= D.Daily
			OR I.InfoBankActual		!= D.Actual
			OR I.InfoBankStart		!= D.Start;

		-- Обновляем состав систем
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


		-- обновляем справочник систем

		UPDATE S
		SET SST_NAME = D.[Name],
			SST_SHORT = D.[Short],
			SST_NOTE = D.[Note]
		FROM Din.SystemType S
		INNER JOIN @SysType D ON S.SST_REG = D.Reg
		WHERE S.SST_NAME != D.[Name]
			OR S.SST_SHORT != D.[Short]
			OR S.SST_NOTE != D.[Note];

		INSERT INTO Din.SystemType(SST_NAME, SST_SHORT, SST_NOTE, SST_REG)
		SELECT D.Name, D.Short, D.Note, D.Reg
		FROM @SysType D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Din.SystemType S
				WHERE S.SST_REG = D.Reg
			);

		-- статусы клиента
		UPDATE S
		SET [ServiceStatusName]		= D.[Name],
			[ServiceStatusIndex]	= D.[Index],
			[ServiceStatusReg]		= D.[Reg],
			[ServiceDefault]		= D.[Default]
		FROM dbo.ServiceStatusTable S
		INNER JOIN @ClientStatus D ON S.[ServiceCode] = D.[Code]
		WHERE S.[ServiceStatusName] != D.[Name]
			OR S.[ServiceStatusIndex] != D.[Index]
			OR S.[ServiceStatusReg] != D.[Reg]
			OR S.[ServiceDefault] != D.[Default];

		INSERT INTO dbo.ServiceStatusTable([ServiceStatusName], [ServiceStatusIndex], [ServiceStatusReg], [ServiceDefault], [ServiceCode])
		SELECT D.[Name], D.[Index], D.[Reg], D.[Default], D.[Code]
		FROM @ClientStatus D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ServiceStatusTable S
				WHERE S.[ServiceCode] = D.[Code]
			);

		-- бизнес-справочник типов сети
		UPDATE N
		SET DistrTypeName		= D.Name,
			DistrTypeOrder		= D.[Order],
			DistrTypeFull		= D.[Full],
			DistrTypeBaseCheck	= D.[BaseCheck]
		FROM dbo.DistrTypeTable N
		INNER JOIN @DistrType D ON N.DistrTypeCode = D.Code
		WHERE N.DistrTypeName != D.Name
			OR N.DistrTypeFull != D.[Full]
			OR N.DistrTypeOrder != D.[Order]
			OR N.DistrTypeBaseCheck != D.BaseCheck;

		INSERT INTO dbo.DistrTypeTable(DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeBaseCheck, DistrTypeCode)
		SELECT Name, [Order], [Full], [BaseCheck], Code
		FROM @DistrType D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DistrTypeTable N
				WHERE N.DistrTypeCode = D.Code
			);

		-- Справочник типов сети
		UPDATE N
		SET NT_NAME = D.Name,
			NT_SHORT = D.Short,
			NT_NOTE = D.Note,
			NT_TECH_USR = D.TechUsr
		FROM Din.NetType N
		INNER JOIN @NetType D ON N.NT_NET = D.NetCnt AND N.NT_TECH = D.Tech AND N.NT_ODON = D.Odon AND N.NT_ODOFF = D.Odoff
		WHERE N.NT_NAME != D.Name
			OR N.NT_SHORT != D.Short
			OR N.NT_NOTE != D.Note
			OR IsNull(N.NT_TECH_USR, '') != IsNull(D.TechUsr, '');

		INSERT INTO Din.NetType(NT_NAME, NT_NOTE, NT_NET, NT_TECH, NT_SHORT, NT_TECH_USR, NT_ODON, NT_ODOFF)
		SELECT Name, Note, NetCnt, Tech, Short, TechUsr, Odon, Odoff
		FROM @NetType D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Din.NetType N
				WHERE N.NT_NET = D.NetCnt AND N.NT_TECH = D.Tech AND N.NT_ODON = D.Odon AND N.NT_ODOFF = D.Odoff
			);

		-- обновляем справочник статусов дистрибутива
		UPDATE S
		SET DS_NAME		= D.[Name],
			DS_INDEX	= D.[Index]
		FROM dbo.DistrStatus S
		INNER JOIN @DistrStatus D ON S.DS_REG = D.Reg
		WHERE S.DS_NAME != D.[Name]
			OR S.DS_INDEX != D.[Index];

		INSERT INTO dbo.DistrStatus(DS_NAME, DS_INDEX, DS_REG)
		SELECT D.Name, D.[Index], D.Reg
		FROM @DistrStatus D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DistrStatus S
				WHERE S.DS_REG = D.Reg
			);

		-- обновляем справочник типов соответствия USR

		UPDATE S
		SET ComplianceTypeShortName	= D.[Short],
			ComplianceTypeOrder		= D.[Order]
		FROM dbo.ComplianceTypeTable S
		INNER JOIN @Compliance D ON S.ComplianceTypeName = D.Name
		WHERE S.ComplianceTypeShortName != D.[Short]
			OR S.ComplianceTypeOrder != D.[Order];

		INSERT INTO dbo.ComplianceTypeTable(ComplianceTypeName, ComplianceTypeShortName, ComplianceTypeOrder)
		SELECT D.Name, D.Short, D.[Order]
		FROM @Compliance D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ComplianceTypeTable S
				WHERE S.ComplianceTypeName = D.Name
			);

		-- обновляем справочник типов формирования файлов USR

		UPDATE S
		SET USRFileKindShortName	= D.[ShortName],
			USRFileKindShort		= D.[Short]
		FROM dbo.USRFileKindTable S
		INNER JOIN @USRKind D ON S.USRFileKindName = D.Name
		WHERE S.USRFileKindShortName != D.[ShortName]
			OR S.USRFileKindShort != D.[Short];

		INSERT INTO dbo.USRFileKindTable(USRFileKindName, USRFileKindShortName, USRFileKindShort)
		SELECT D.Name, D.ShortName, D.Short
		FROM @USRKind D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.USRFileKindTable S
				WHERE S.USRFileKindName = D.Name
			);

		-- обновляем справочник типов сотрудников

		UPDATE S
		SET CPT_NAME		= D.[Name],
			CPT_SHORT		= D.[Short],
			CPT_REQUIRED	= D.[Required],
			CPT_ORDER		= D.[Order]
		FROM dbo.ClientPersonalType S
		INNER JOIN @PersonalType D ON S.CPT_PSEDO = D.Psedo
		WHERE S.CPT_NAME != D.[Name]
			OR S.CPT_SHORT != D.[Short]
			OR S.CPT_REQUIRED != D.[Required]
			OR S.CPT_ORDER != D.[Order];

		INSERT INTO dbo.ClientPersonalType(CPT_NAME, CPT_SHORT, CPT_PSEDO, CPT_REQUIRED, CPT_ORDER)
		SELECT D.[Name], D.[Short], D.[Psedo], D.[Required], D.[Order]
		FROM @PersonalType D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientPersonalType S
				WHERE S.CPT_PSEDO = D.Psedo
			);

		-- обновляем список дистрибутивов подключенных к ЗВЭ
		TRUNCATE TABLE dbo.ExpertDistr;

		INSERT INTO dbo.ExpertDistr(ID_HOST, DISTR, COMP, SET_DATE)
		SELECT HostID, Distr, Comp, Date
		FROM
		(
			SELECT
				[Host]	= V.value('@Host[1]',		'VarChar(100)'),
				[Distr]	= V.value('@Distr[1]',		'Int'),
				[Comp]	= V.value('@Comp[1]',		'TinyInt'),
				[Date]	= V.value('@Date[1]',		'DateTime')
			FROM @Data.nodes('/DATA[1]/EXPERT[1]/ITEM') N(V)
		) AS D
		INNER JOIN dbo.Hosts H ON H.HostReg = D.Host;

		-- обновляем списко дистрибутивов подключенных к чату

		TRUNCATE TABLE dbo.HotlineDistr;

		INSERT INTO dbo.HotlineDistr(ID_HOST, DISTR, COMP, SET_DATE)
		SELECT HostID, Distr, Comp, Date
		FROM
		(
			SELECT
				[Host]	= V.value('@Host[1]',		'VarChar(100)'),
				[Distr]	= V.value('@Distr[1]',	'Int'),
				[Comp]	= V.value('@Comp[1]',		'TinyInt'),
				[Date]	= V.value('@Date[1]',		'DateTime')
			FROM @Data.nodes('/DATA[1]/HOTLINE[1]/ITEM') N(V)
		) AS D
		INNER JOIN dbo.Hosts H ON H.HostReg = D.Host;

		-- Обновляем черный список ИП

		TRUNCATE TABLE dbo.BLACK_LIST_REG;

		INSERT INTO dbo.BLACK_LIST_REG(ID_SYS, DISTR, COMP, DATE, P_DELETE)
		SELECT SystemID, Distr, Comp, Date, 0
		FROM
		(
			SELECT
				[Sys]	= V.value('@Sys[1]',		'VarChar(100)'),
				[Distr]	= V.value('@Distr[1]',	'Int'),
				[Comp]	= V.value('@Comp[1]',		'TinyInt'),
				[Date]	= V.value('@Date[1]',		'DateTime')
			FROM @Data.nodes('/DATA[1]/BLACK[1]/ITEM') N(V)
		) AS D
		INNER JOIN dbo.SystemTable S ON D.Sys = S.SystemBaseName;

		-- Обновляем протокол РЦ

		INSERT INTO dbo.RegProtocol(RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER)
		SELECT Date, HostID, Distr, Comp, Oper, Reg, [Type], [Text], [User], Computer
		FROM
		(
			SELECT
				[Host]		= V.value('@Host[1]',		'VarChar(100)'),
				[Distr]		= V.value('@Distr[1]',		'Int'),
				[Comp]		= V.value('@Comp[1]',		'TinyInt'),
				[Date]		= V.value('@Date[1]',		'DateTime'),
				[Oper]		= V.value('@Oper[1]',		'VarChar(200)'),
				[Reg]		= V.value('@Reg[1]',		'VarChar(200)'),
				[Type]		= V.value('@Type[1]',		'VarChar(200)'),
				[Text]		= V.value('@Text[1]',		'VarChar(200)'),
				[User]		= V.value('@User[1]',		'VarChar(200)'),
				[Computer]	= V.value('@Computer[1]',	'VarChar(200)')
			FROM @Data.nodes('/DATA[1]/PROT[1]/ITEM') N(V)
		) D
		INNER JOIN dbo.Hosts H ON H.HostReg = D.Host
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.RegProtocol R
				WHERE R.RPR_ID_HOST = H.HostID
					AND R.RPR_DISTR = D.Distr
					AND R.RPR_COMP = D.Comp
					AND R.RPR_DATE = D.Date
					AND R.RPR_TEXT = D.[Text]
					AND R.RPR_OPER = D.[Oper]
					AND R.RPR_TYPE = D.[Type]
			);

		-- Обновляем текстовый протокол РЦ

		INSERT INTO Reg.ProtocolText(ID_HOST, DATE, DISTR, COMP, CNT, COMMENT)
		SELECT HostID, Date, Distr, Comp, Cnt, Comment
		FROM
		(
			SELECT
				[Host]		= V.value('@Host[1]',		'VarChar(100)'),
				[Distr]		= V.value('@Distr[1]',	'Int'),
				[Comp]		= V.value('@Comp[1]',		'TinyInt'),
				[Date]		= V.value('@Date[1]',		'DateTime'),
				[Cnt]		= V.value('@Cnt[1]',		'Int'),
				[Comment]	= V.value('@Comment[1]',	'VarChar(200)')
			FROM @Data.nodes('/DATA[1]/PROT_TEXT[1]/ITEM') N(V)
		) D
		INNER JOIN dbo.Hosts H ON D.Host = H.HostReg
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Reg.ProtocolText R
				WHERE R.ID_HOST = H.HostID
					AND R.DISTR = D.Distr
					AND R.COMP = D.Comp
					AND R.DATE = D.Date
					AND R.COMMENT = D.Comment
			);

		-- Обновляем прейкурант

		INSERT INTO Price.SystemPrice(ID_SYSTEM, ID_MONTH, PRICE)
		SELECT DISTINCT SystemID, ID, PRICE
		FROM
		(
			SELECT
				[Sys]	= V.value('@Sys[1]',	'VarChar(100)'),
				[Date]	= V.value('@Date[1]',	'SmallDateTime'),
				[Price]	= V.value('@Price[1]',	'Money')
			FROM @Data.nodes('/DATA[1]/PRICE[1]/ITEM') N(V)
		) AS D
		INNER JOIN dbo.SystemTable S ON SystemBaseName = SYS
		INNER JOIN Common.Period P ON START = DATE AND TYPE = 2
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Price.SystemPrice SP
				WHERE SP.ID_SYSTEM = SystemID
					AND SP.ID_MONTH = P.ID
			);

		-- обновляем количество документов

		INSERT INTO dbo.StatisticTable(StatisticDate, InfoBankID, Docs)
		SELECT IDate, y.InfoBankID, IDOCS
		FROM
			(
				SELECT
					c.value('(@IB)', 'VARCHAR(50)') AS IBase,
					c.value('(@Date)', 'SmallDateTime') AS IDate,
					c.value('(@Docs)', 'INT') AS IDOCS
				FROM @Data.nodes('/DATA[1]/STAT[1]/ITEM') AS a(c)
			) AS z
			INNER JOIN dbo.InfoBankTable y ON z.IBase = y.InfoBankName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.StatisticTable x
				WHERE x.InfoBankID = y.InfoBankID
					AND z.IDate = x.StatisticDate
					AND x.Docs = z.IDOCS
			)

		-- Обновляем РЦ

		DELETE FROM dbo.RegNodeTable;

		INSERT INTO dbo.RegNodeTable(
					SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft,
					Service, RegisterDate, Comment, Complect, ODOn, ODOff
					)
		SELECT
			V.value('@Sys[1]',		'VarChar(100)'),
			V.value('@Distr[1]',	'Int'),
			V.value('@Comp[1]',		'TinyInt'),
			V.value('@DisType[1]',	'VarChar(100)'),
			V.value('@TechType[1]',	'SmallInt'),
			V.value('@NetCnt[1]',	'SmallInt'),
			V.value('@SubHost[1]',	'Bit'),
			V.value('@TrnCnt[1]',	'SmallInt'),
			V.value('@TrnLeft[1]',	'SmallInt'),
			V.value('@Service[1]',	'SmallInt'),
			Convert(VarChar(20), V.value('@RegDate[1]',	'SmallDateTime'), 104),
			V.value('@Comment[1]',	'VarChar(100)'),
			V.value('@Complect[1]',	'VarChar(100)'),
			V.value('@ODon[1]',		'SmallInt'),
			V.value('@ODoff[1]',	'SmallInt')
		FROM @Data.nodes('/DATA[1]/REG[1]/ITEM') N(V);

		DELETE FROM dbo.Weight;

		INSERT INTO dbo.Weight(Date, Sys, SysType, NetCount, NetTech, NetOdon, NetOdoff, Weight)
		SELECT
			V.value('@Date[1]',		'SmallDateTime'),
			V.value('@Sys[1]',		'VarChar(100)'),
			V.value('@SysType[1]',	'VarChar(100)'),
			V.value('@NetCount[1]',	'SmallInt'),
			V.value('@NetTech[1]',	'SmallInt'),
			V.value('@NetOdon[1]',	'SmallInt'),
			V.value('@NetOdoff[1]',	'SmallInt'),
			V.value('@Weight[1]',	'Decimal(8,4)')
		FROM @Data.nodes('/DATA[1]/REFERENCES[1]/WEIGHT[1]/ITEM') N(V);

		INSERT INTO @Coef
		SELECT DISTINCT
			[ID_NET],
			[COEF],
			[RND],
			[START],
			[FINISH]
		FROM
		(
			SELECT
				ID_NET = N.NT_ID_MASTER,
				P.PERIODS
			FROM
			(
				SELECT
					[NT_NET]	= C.value('@NT_NET[1]',		'SmallInt'),
					[NT_TECH]	= C.value('@NT_TECH[1]',	'SmallInt'),
					[NT_ODON]	= C.value('@NT_ODON[1]',	'SmallInt'),
					[NT_ODOFF]	= C.value('@NT_ODOFF[1]',	'SmallInt'),
					[PERIODS]	= C.query('./PERIODIC')
				FROM @Data.nodes('/DATA[1]/REFERENCES[1]/DISTR_TYPE_COEF[1]/ITEM') N(C)
			) P
			INNER JOIN Din.NetType N ON N.NT_NET = P.NT_NET
									AND N.NT_TECH = P.NT_TECH
									AND N.NT_ODON = P.NT_ODON
									AND N.NT_ODOFF = P.NT_ODOFF
		) N
		CROSS APPLY
		(
			SELECT
				[COEF]		= C.value('@COEF[1]',	'Decimal(8,4)'),
				[RND]		= C.value('@RND[1]',	'SmallInt'),
				[START]		= C.value('@START[1]',	'SmallDateTime'),
				[FINISH]	= C.value('@FINISH[1]',	'SmallDateTime')
			FROM N.PERIODS.nodes('/PERIODIC/PERIOD') P(C)
		) AS P
		WHERE ID_NET IS NOT NULL;

		UPDATE C
		SET COEF	= N.COEF,
			RND		= N.RND
		FROM dbo.DistrTypeCoef C
		INNER JOIN
		(
			SELECT
				C.ID_NET, C.COEF, C.RND, ID_MONTH = P.ID
			FROM @Coef C
			CROSS APPLY
			(
				SELECT P.ID
				FROM Common.Period P
				WHERE TYPE = 2
					AND P.START >= C.START
					AND (P.START <= C.FINISH OR C.FINISH IS NULL)
			) AS P
		) N ON C.ID_NET = N.ID_NET AND C.ID_MONTH = N.ID_MONTH
		WHERE C.COEF != N.COEF OR C.RND != N.RND;

		INSERT INTO dbo.DistrTypeCoef(ID_NET, ID_MONTH, COEF, RND)
		SELECT DISTINCT C.ID_NET, P.ID, C.COEF, C.RND
		FROM @Coef C
		CROSS APPLY
		(
			SELECT P.ID
			FROM Common.Period P
			WHERE TYPE = 2
				AND P.START >= C.START
				AND (P.START <= C.FINISH OR C.FINISH IS NULL)
		) AS P
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DistrTypeCoef Q
				WHERE	Q.ID_NET = C.ID_NET
					AND Q.ID_MONTH = P.ID
			);

		INSERT INTO @SystemBanksNew
		SELECT DISTINCT
			[System],
			[DistrType],
			I.[InfoBankId],
			[Required],
			[START]
		FROM
		(
			SELECT
				[DistrType] = N.[NT_ID_MASTER],
				[System]	= S.[SystemId],
				P.INFO_BANKS
			FROM
			(
				SELECT
					[System]		= C.value('@SystemBaseName[1]',		'VarChar(100)'),
					[NT_NET]		= C.value('@NT_NET[1]',				'SmallInt'),
					[NT_TECH]		= C.value('@NT_TECH[1]',			'SmallInt'),
					[NT_ODON]		= C.value('@NT_ODON[1]',			'SmallInt'),
					[NT_ODOFF]		= C.value('@NT_ODOFF[1]',			'SmallInt'),
					[INFO_BANKS]	= C.query('./INFO_BANKS')
				FROM @Data.nodes('/DATA[1]/REFERENCES[1]/SYSTEM_BANK_NEW[1]/ITEM') N(C)
			) P
			INNER JOIN Din.NetType N ON N.NT_NET = P.NT_NET
									AND N.NT_TECH = P.NT_TECH
									AND N.NT_ODON = P.NT_ODON
									AND N.NT_ODOFF = P.NT_ODOFF
			INNER JOIN dbo.SystemTable S ON S.SystemBaseName = P.[System]
		) N
		CROSS APPLY
		(
			SELECT
				[InfoBank]	= C.value('@InfoBankName[1]',	'VarChar(100)'),
				[Required]	= C.value('@Required[1]',		'Bit'),
				[START]		= C.value('Start[1]',			'SmallDateTime')
			FROM N.INFO_BANKS.nodes('/INFO_BANKS/ITEM') P(C)
		) AS P
		INNER JOIN dbo.InfoBankTable I ON I.[InfoBankName] = P.[InfoBank];

		DELETE SB
		FROM dbo.SystemsBanks SB
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @SystemBanksNew Z
				WHERE Z.[System] = SB.[System_Id]
					AND Z.[DistrType] = SB.[DistrType_Id]
					AND Z.[InfoBank] = SB.[InfoBank_Id]
			);

		INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, Required, Start)
		SELECT System, DistrType, InfoBank, Required, Start
		FROM @SystemBanksNew Z
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemsBanks SB
				WHERE Z.[System] = SB.[System_Id]
					AND Z.[DistrType] = SB.[DistrType_Id]
					AND Z.[InfoBank] = SB.[InfoBank_Id]
			);

		UPDATE SB
		SET Required	= Z.Required,
			Start		= Z.Start
		FROM dbo.SystemsBanks SB
		INNER JOIN @SystemBanksNew Z ON Z.[System] = SB.[System_Id]
									AND Z.[DistrType] = SB.[DistrType_Id]
									AND Z.[InfoBank] = SB.[InfoBank_Id]
		WHERE Z.Required != SB.Required
			OR IsNull(SB.Start, '20000101') != IsNull(Z.Start, '20000101');

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[IMPORT_ALL_NEW_DATA] TO rl_import_data;
GO
