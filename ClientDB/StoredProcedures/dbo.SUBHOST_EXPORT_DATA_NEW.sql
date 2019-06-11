USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SUBHOST_EXPORT_DATA_NEW]
	@SH		NVARCHAR(32)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SUBHOST	UniqueIdentifier;

	DECLARE @SH_REG_ADD VarChar(20)
	DECLARE @SH_REG		VarChar(20)

	SELECT @SUBHOST = SH_ID, @SH_REG = SH_REG, @SH_REG_ADD = SH_REG_ADD
	FROM dbo.Subhost
	WHERE SH_REG = @SH

	SET @SH_REG = '(' + @SH_REG + ')%'
	SET @SH_REG_ADD = '(' + @SH_REG_ADD + ')%'

	DECLARE
		@Data		Xml,
		@Stat		Xml,
		@Reg		Xml,
		@ProtTxt	Xml,
		@Prot		Xml,
		@Price		Xml,
		@Black		Xml,
		@Expert		Xml,
		@Hotline	Xml,
		@Net		Xml,
		@Type		Xml,
		@Host		Xml,
		@System		Xml,
		@InfoBank	Xml,
		@SystemBank	Xml,
		@Weight		Xml,
		@References	Xml;
	
	DECLARE @Distr Table
	(
		HostID	SmallInt	NOT NULL,
		Distr	Int			NOT NULL,
		Comp	TinyInt		NOT NULL,
		Primary Key Clustered(Distr, HostID, Comp)
	);
	
	INSERT INTO @Distr
	SELECT HostID, DistrNumber, CompNumber
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
	WHERE (Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD) AND SystemReg = 1

	UNION

	SELECT b.HostID, DistrNumber, CompNumber
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
	WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

	UNION 

	SELECT HostID, DistrNumber, CompNumber
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
	WHERE Complect IN
		(
			SELECT Complect
			FROM 
				dbo.RegNodeTable a
				INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
				INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
			WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
		);
	
	SET @Stat = 
		(
			SELECT --TOP 10
				[IB]	= InfoBankName,
				[Date]	= StatisticDate,
				[Docs]	= Docs
			FROM
			(
				SELECT StatisticDate, InfoBankName, Docs
				FROM 
					dbo.StatisticTable a 
					INNER JOIN dbo.SystemBanksView b WITH(NOEXPAND) ON a.InfoBankID = b.InfoBankID
				WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
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
			INNER JOIN dbo.ExpDistr E ON E.ID_HOST = D.HostID AND D.Distr = E.DISTR AND D.Comp = E.COMP
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
						@Weight
					FOR XML PATH('REFERENCES')	
				)
			)
		);
	
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
					@References
				FOR XML PATH('DATA')
			)
		);
			
	SELECT [DATA] = Cast(@Data AS NVarChar(Max))
END
