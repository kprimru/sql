USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_EXPORT_DATA_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_EXPORT_DATA_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_EXPORT_DATA_NEW]
	@SH		NVARCHAR(32)
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

		DECLARE @SUBHOST	UniqueIdentifier;

		DECLARE @SH_REG_ADD VarChar(20)
		DECLARE @SH_REG		VarChar(20)

		SELECT @SUBHOST = SH_ID, @SH_REG = SH_REG, @SH_REG_ADD = SH_REG_ADD
		FROM dbo.Subhost
		WHERE SH_REG = @SH

		SET @SH_REG = '(' + @SH_REG + ')%'
		SET @SH_REG_ADD = '(' + @SH_REG_ADD + ')%'

		DECLARE
			@Data					Xml,
			@Stat					Xml,
			@Reg					Xml,
			@ProtTxt				Xml,
			@Prot					Xml,
			@Price					Xml,
			@Black					Xml,
			@Expert					Xml,
			@Hotline				Xml,
			@Net					Xml,
			@Type					Xml,
			@Host					Xml,
			@System					Xml,
			@InfoBank				Xml,
			@SystemBank				Xml,
			@SystemBankNew			Xml,
			@Weight					Xml,
			@DistrStatus			Xml,
			@Compliance				Xml,
			@USRKind				Xml,
			@PersonalType			Xml,
			@References				Xml,
			@NamedSets				Xml,
			@ServiceStatusNamedSet	Xml,
			@DistrType				Xml,
			@ClientStatus			Xml,
			@DistrCoef				Xml;

		DECLARE @Distr Table
		(
			HostID	SmallInt	NOT NULL,
			Distr	Int			NOT NULL,
			Comp	TinyInt		NOT NULL,
			Primary Key Clustered(Distr, HostID, Comp)
		);

		DECLARE @DistrTypeCoef Table
		(
			ID_NET	SmallInt			NOT NULL,
			START	SmallDateTime		NOT NULL,
			COEF	Decimal(8,4)		NOT NULL,
			RND		SmallInt			NOT NULL,
			Primary Key Clustered(ID_NET, START)
		);

		INSERT INTO @Distr
		SELECT HostID, DistrNumber, CompNumber
		FROM dbo.SubhostDistrs@Get(NULL, @SH);

		SET @Stat =
			(
				SELECT --TOP 10
					[IB]	= InfoBankName,
					[Date]	= StatisticDate,
					[Docs]	= Docs
				FROM
				(
					SELECT DISTINCT StatisticDate, InfoBankName, Docs
					FROM
						dbo.StatisticTable a
						INNER JOIN dbo.InfoBankTable b ON a.InfoBankID = b.InfoBankID
					WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -3, GETDATE()))
				) AS a
			FOR XML RAW('ITEM'), ROOT('STAT')
		)

		SET @Reg =
			(
				SELECT --TOP 10
					[Sys]		= SystemBaseName,
					[Distr]		= DistrNumber,
					[Comp]		= CompNumber,
					[DisType]	= DistrType,
					[TechType]	= TechnolType,
					[NetCnt]	= NetCount,
					[SubHost]	= SubHost,
					[TrnCnt]	= TransferCount,
					[TrnLeft]	= TransferLeft,
					[Service]	= Service,
					[RegDate]	= RegisterDate,
					[Comment]	= Comment,
					[Complect]	= Complect,
					[ODon]		= ODon,
					[ODoff]		= ODoff
				FROM dbo.RegNodeTable R
				INNER JOIN dbo.SystemTable S ON R.SystemName = S.SystemBaseName
				INNER JOIN @Distr D ON D.HostID = S.HostID AND D.Distr = R.DistrNumber AND D.Comp = R.CompNumber
				FOR XML RAW('ITEM'), ROOT('REG')
			)

		SET @ProtTxt =
			(
				SELECT --TOP 10
					[Host]		= HostReg,
					[Distr]		= R.Distr,
					[Comp]		= R.Comp,
					[Date]		= DATE,
					[Cnt]		= CNT,
					[Comment]	= COMMENT
				FROM Reg.ProtocolText AS R
				INNER JOIN @Distr D ON R.ID_HOST = D.HostID AND R.DISTR = D.DISTR AND R.COMP = D.COMP
				INNER JOIN dbo.Hosts H ON H.HostID = D.HostID
				WHERE DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
				FOR XML RAW('ITEM'), ROOT('PROT_TEXT')
			);

		SET @Prot =
			(
				SELECT --TOP 10
					[Host]		= HostReg,
					[Distr]		= R.RPR_DISTR,
					[Comp]		= R.RPR_COMP,
					[Date]		= RPR_DATE,
					[Oper]		= RPR_OPER,
					[Reg]		= RPR_REG,
					[Type]		= RPR_TYPE,
					[Text]		= RPR_TEXT,
					[User]		= RPR_USER,
					[Computer]	= RPR_COMPUTER
				FROM dbo.RegProtocol AS R
				INNER JOIN @Distr D ON R.RPR_ID_HOST = HostID AND R.RPR_DISTR = D.Distr AND R.RPR_COMP = D.Comp
				INNER JOIN dbo.Hosts H ON H.HostID = D.HostID
				WHERE RPR_DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
				FOR XML RAW('ITEM'), ROOT('PROT')
			);

		SET @Price =
			(
				SELECT --TOP 10
					[Sys]	= SystemBaseName,
					[Date]	= b.START,
					[Price]	= PRICE
				FROM Price.SystemPrice a
				INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
				INNER JOIN dbo.SystemTable c ON c.SystemID = a.ID_SYSTEM
				WHERE START >= dbo.DateOf(DATEADD(MONTH, -6, GETDATE()))
				FOR XML RAW('ITEM'), ROOT('PRICE')
			);

		SET @Black  =
			(
				SELECT --TOP 10
					[Sys]	= SystemBaseName,
					[Distr]	= B.Distr,
					[Comp]	= B.Comp,
					[Date]	= B.DATE
				FROM @Distr D
				INNER JOIN dbo.SystemTable S ON S.HostID = D.HostID
				INNER JOIN dbo.BLACK_LIST_REG B ON b.ID_SYS = S.SystemID AND D.Distr = b.DISTR AND D.Comp = b.COMP
				WHERE P_DELETE = 0
				FOR XML RAW('ITEM'), ROOT('BLACK')
			);

		SET @Expert =
			(
				SELECT --TOP 10
					[Host]	= HostReg,
					[Distr]	= E.Distr,
					[Comp]	= E.Comp,
					[Date]	= SET_DATE
				FROM @Distr D
				INNER JOIN dbo.ExpertDistr E ON E.ID_HOST = D.HostID AND D.Distr = E.DISTR AND D.Comp = E.COMP
				INNER JOIN dbo.Hosts H ON H.HostID = E.ID_HOST
				WHERE UNSET_DATE IS NULL
				FOR XML RAW('ITEM'), ROOT('EXPERT')
			);

		SET @Hotline =
			(
				SELECT --TOP 10
					[Host]	= HostReg,
					[Distr]	= E.Distr,
					[Comp]	= E.Comp,
					[Date]	= SET_DATE
				FROM @Distr D
				INNER JOIN dbo.HotlineDistr E ON E.ID_HOST = D.HostID AND D.Distr = E.DISTR AND D.Comp = E.COMP
				INNER JOIN dbo.Hosts H ON H.HostID = E.ID_HOST
				WHERE UNSET_DATE IS NULL
				FOR XML RAW('ITEM'), ROOT('HOTLINE')
			);

		SET @Net =
			(
				SELECT
					[Name]		= NT_NAME,
					[Note]		= NT_NOTE,
					[NetCnt]	= NT_NET,
					[Tech]		= NT_TECH,
					[Short]		= NT_SHORT,
					[TechUsr]	= NT_TECH_USR,
					[Odon]		= NT_ODON,
					[Odoff]		= NT_ODOFF
				FROM Din.NetType
				FOR XML RAW('ITEM'), ROOT('NET')
			);

		SET @Type =
			(
				SELECT
					[Name]	= SST_NAME,
					[Short]	= SST_SHORT,
					[Note]	= SST_NOTE,
					[Reg]	= SST_REG
				FROM Din.SystemType
				FOR XML RAW('ITEM'), ROOT('SYS_TYPE')
			);

		SET @InfoBank =
			(
				SELECT
					[Name]		= InfoBankName,
					[Short]		= InfoBankShortName,
					[Full]		= InfoBankFullName,
					[Order]		= InfoBankOrder,
					[Active]	= InfoBankActive,
					[Daily]		= InfoBankDaily,
					[Actual]	= InfoBankActual,
					[Start]		= InfoBankStart
				FROM dbo.InfoBankTable
				FOR XML RAW('ITEM'), ROOT('INFO_BANK')
			);

		SET @Host =
			(
				SELECT
					[Short]	= HostShort,
					[Reg]	= HostReg,
					[Order]	= HostOrder
				FROM dbo.Hosts
				FOR XML RAW('ITEM'), ROOT('HOST')
			);

		SET @System =
			(
				SELECT
					[Short]		= SystemShortName,
					[Name]		= SystemName,
					[RegName]	= SystemBaseName,
					[Number]	= SystemNumber,
					[Host]		= HostReg,
					[Ric]		= SystemRic,
					[Order]		= SystemOrder,
					[VMI]		= SystemVMI,
					[Full]		= SystemFullName,
					[Din]		= SystemDin,
					[Active]	= SystemActive,
					[Start]		= SystemStart,
					[End]		= SystemEnd,
					[Demo]		= SystemDemo,
					[Complect]	= SystemComplect,
					[Reg]		= SystemReg,
					[BaseCheck]	= SystemBaseCheck
				FROM dbo.SystemTable S
				INNER JOIN dbo.Hosts H ON S.HostID = H.HostID
				FOR XML RAW('ITEM'), ROOT('SYSTEM')
			);

		SET @SystemBank =
			(
				SELECT
					[System]	= SystemBaseName,
					[InfoBank]	= InfoBankName,
					[Required]	= Required
				FROM dbo.SystemBanksView WITH(NOEXPAND)
				FOR XML RAW('ITEM'), ROOT('SYSTEM_BANK')
			);

		-- TOdo исправить после синхронизации справочника dbo.DistrTypeTable
		SET @SystemBankNew =
			(
				SELECT
					SystemBaseName,
					NT_NET,
					NT_TECH,
					NT_ODON,
					NT_ODOFF,
					[INFO_BANKS] =
					(
						SELECT
							InfoBankName,
							Required,
							Start
						FROM dbo.SystemsBanks SB
						INNER JOIN dbo.InfoBankTable I ON SB.InfoBank_Id = I.InfoBankID
						WHERE SB.System_Id = SD.System_Id
							AND SB.DistrType_Id = SD.DIstrType_Id
						FOR XML RAW('ITEM'), TYPE
					)
				FROM
				(
					SELECT DISTINCT SystemBaseName, NT_NET, NT_TECH, NT_ODON, NT_ODOFF, System_Id, DistrType_Id
					FROM dbo.SystemsBanks SB
					INNER JOIN dbo.SystemTable S ON SB.System_Id = S.SystemId
					INNER JOIN Din.NetType N ON N.NT_ID_MASTER = SB.DIstrType_Id
				) SD
				FOR XML RAW('ITEM'), ROOT('SYSTEM_BANK_NEW')
			);

		SET @Weight =
			(
				SELECT
					[Date]		= W.[Date],
					[Sys]		= W.[Sys],
					[SysType]	= W.[SysType],
					[NetCount]	= W.[NetCount],
					[NetTech]	= W.[NetTech],
					[NetOdon]	= W.[NetOdon],
					[NetOdoff]	= W.[NetOdoff],
					[Weight]	= W.[Weight]
				FROM dbo.Weight W
				FOR XML RAW('ITEM'), ROOT('WEIGHT')
			);

		SET @DistrStatus =
			(
				SELECT
					[Name]	= DS_NAME,
					[Reg]	= DS_REG,
					[Index]	= DS_INDEX
				FROM dbo.DistrStatus
				FOR XML RAW('ITEM'), ROOT('DISTR_STATUS')
			);

		SET @Compliance =
			(
				SELECT
					[Name]	= ComplianceTypeName,
					[Short]	= ComplianceTypeShortName,
					[Order]	= ComplianceTypeOrder
				FROM dbo.ComplianceTypeTable
				FOR XML RAW('ITEM'), ROOT('COMPLIANCE')
			);

		SET @USRKind =
			(
				SELECT
					[Name]		= USRFileKindName,
					[ShortName]	= USRFileKindShortName,
					[Short]		= USRFileKindShortName
				FROM dbo.USRFileKindTable
				FOR XML RAW('ITEM'), ROOT('USR_KIND')
			);

		SET @PersonalType =
			(
				SELECT
					[Name]		= CPT_NAME,
					[Short]		= CPT_SHORT,
					[Psedo]		= CPT_PSEDO,
					[Required]	= CPT_REQUIRED,
					[Order]		= CPT_ORDER
				FROM dbo.ClientPersonalType
				FOR XML RAW('ITEM'), ROOT('PERSONAL_TYPE')
			);

		SET @ClientStatus =
			(
				SELECT
					[Name]		= ServiceStatusName,
					[Reg]		= ServiceStatusReg,
					[Index]		= ServiceStatusIndex,
					[Default]	= ServiceDefault,
					[Code]		= ServiceCode
				FROM dbo.ServiceStatusTable
				FOR XML RAW('ITEM'), ROOT('CLIENT_STATUS')
			);

		SET @DistrType =
			(
				SELECT
					[Name]		= DistrTypeName,
					[Order]		= DistrTypeOrder,
					[Full]		= DistrTypeFull,
					[BaseCheck]	= DistrTypeBaseCheck,
					[Code]		= DistrTypeCode
				FROM dbo.DistrTypeTable
				FOR XML RAW('ITEM'), ROOT('DISTR_TYPE')
			);

		-- TOdo исправить после синхронизации справочника dbo.DistrTypeTable
		INSERT INTO @DistrTypeCoef
		SELECT ID_NET, START, COEF, RND
		FROM
		(
			SELECT ID_NET, COEF, RND, P.START, Row_Number() OVER(PARTITION BY ID_NET, COEF, RND ORDER BY P.START) AS RN
			FROM dbo.DistrTypeCoef C
			INNER JOIN Common.Period P ON C.ID_MONTH = P.ID
		) AS A
		WHERE RN = 1;

		SET @DistrCoef =
		(
			SELECT
				NT_NET,
				NT_TECH,
				NT_ODON,
				NT_ODOFF,
				PERIODIC =
				(
					SELECT
						COEF,
						RND,
						START,
						FINISH
					FROM @DistrTypeCoef P
					OUTER APPLY
					(
						SELECT TOP (1) FINISH = DateAdd(Month, -1, N.START)
						FROM @DistrTypeCoef N
						WHERE P.ID_NET = N.ID_NET
							AND N.START > P.START
						ORDER BY N.START
					) N
					WHERE P.ID_NET = C.ID_NET
					FOR XML RAW('PERIOD'), TYPE
				)
			FROM
			(
				SELECT DISTINCT ID_NET, NT_NET, NT_TECH, NT_ODON, NT_ODOFF
				FROM @DistrTypeCoef		C
				INNER JOIN Din.NetType	N ON C.ID_NET = N.NT_ID_MASTER
			) C
			FOR XML RAW ('ITEM'), ROOT('DISTR_TYPE_COEF')
		);

		SET @References =
			(
				SELECT
				(
					SELECT
					(
						SELECT
							@Net,
							@Type,
							@InfoBank,
							@Host,
							@System,
							@SystemBank,
							@SystemBankNew,
							@Weight,
							@DistrStatus,
							@Compliance,
							@USRKind,
							@PersonalType,
							@DistrType,
							@ClientStatus,
							@DistrCoef
						FOR XML PATH('REFERENCES')
					)
				)
			);

		SET @ServiceStatusNamedSet =
			(
				SELECT
					[SetId],
					[RefName],
					[SetName],
					[ITEMS] =
						(
							SELECT
								[Code] = T.[ServiceCode]
							FROM dbo.NamedSetsItems I
							INNER JOIN dbo.ServiceStatusTable T ON Cast(I.SetItem AS SmallInt) = T.ServiceStatusId
							WHERE I.SetId = S.SetId
							FOR XML RAW('ITEM'), TYPE
						)
				FROM dbo.NamedSets S
				WHERE RefName = 'dbo.ServiceStatusTable'
				FOR XML RAW('SET'), ROOT('SERVCICE_STATUS_NAMED_SETS')
			);

		SET @NamedSets =
		(
			SELECT
				@ServiceStatusNamedSet
			FOR XML PATH('NAMED_SETS')
		)

		SET @Data =
			(
				SELECT
				(
					SELECT
						@Stat,
						@Reg,
						@ProtTxt,
						@Prot,
						@Price,
						@Black,
						@Expert,
						@Hotline,
						@References,
						@NamedSets
					FOR XML PATH('DATA')
				)
			);

		SELECT [DATA] = Cast(@Data AS NVarChar(Max))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
