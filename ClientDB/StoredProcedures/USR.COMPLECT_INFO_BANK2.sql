USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[COMPLECT_INFO_BANK2]
	@UF_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SET LANGUAGE RUSSIAN

	DECLARE
		@DAILY		TINYINT,
		@DAY		TINYINT,
		@CLIENT		INT,
		@UD_ID		UNIQUEIDENTIFIER,
		@MIN		SMALLDATETIME,
		@MAX		SMALLDATETIME,
		@DS_ID		UNIQUEIDENTIFIER,
		@UF_DATE	DATETIME;

	SELECT @DS_ID = DS_ID
	FROM dbo.DistrStatus
	WHERE DS_REG = 0

	SELECT @CLIENT = UD_ID_CLIENT, @UD_ID = UF_ID_COMPLECT, @MIN = UF_MIN_DATE, @MAX = UF_MAX_DATE, @UF_DATE = UF_DATE
	FROM USR.USRData
	INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID
	WHERE UF_ID = @UF_ID;
	
	SELECT @DAILY = ClientTypeDailyDay, @DAY = ClientTypeDay
	FROM 
		dbo.ClientTypeTable a 
		INNER JOIN dbo.ClientTypeAllView z ON CATEGORY = ClientTypeName		
	WHERE z.ClientID = @CLIENT

	DECLARE @Result Table
	(
		ID				Int Identity(1,1)	NOT NULL Primary Key Clustered,
		ID_MASTER		Int						NULL,
		NAME			VarChar(100)		NOT NULL,
		Service			TinyInt					NULL		,
		UIU_DAY			VarChar(100)			NULL,
		UIU_DOCS		BigInt					NULL,
		UIU_DATE		SmallDateTime			NULL,
		Compliance		TinyInt					NULL,
		USRKind			TinyInt					NULL,
		StandartDate	SmallDateTime			NULL,
		Standart		VarCHar(100)			NULL,
		Format			TinyInt					NULL,
		DataType		TinyInt					NULL
	);

	DECLARE @Systems Table
	(
		SystemId		SmallInt			NOT NULL Primary Key Clustered,
		Distr			Int					NOT NULL,
		Comp			TinyInt				NOT NULL,
		IsExists		Bit					NOT NULL,
		Ric				SmallInt				NULL,
		Net				SmallInt				NULL,
		Tech			VarChar(20)				NULL,
		Type			VarChar(20)				NULL,
		Format			SmallInt				NULL
	);
	
	DECLARE @InfoBanks Table
	(
		InfoBankId		SmallInt			NOT NULL Primary Key Clustered,
		Distr			Int					NOT NULL,
		Comp			TinyInt				NOT NULL,
		IsExists		Bit					NOT NULL,
		Compliance		TinyInt					NULL
	);

	DECLARE @Updates Table
	(
		InfoBankId		SmallInt			NOT NULL,
		Indx			TinyInt				NOT NULL,
		Date			SmallDateTime		NOT NULL,
		Docs			Int					NOT NULL,
		Kind			TinyInt				NOT NULL,
		SysDate			SmallDateTime		NOT NULL,
		Unique(InfoBankId, Indx)
	);

	INSERT INTO @InfoBanks(InfoBankId, Distr, Comp, IsExists, Compliance)
	SELECT UI_ID_BASE, UI_DISTR, UI_COMP, 1, UI_ID_COMP
	FROM USR.USRIB
	WHERE UI_ID_USR = @UF_ID
	
	INSERT INTO @Systems(SystemId, Distr, Comp, IsExists, Ric, Net, Tech, Type, Format)
	SELECT UP_ID_SYSTEM, UP_DISTR, UP_COMP, 1, UP_RIC, UP_NET, UP_TECH, UP_TYPE, UP_FORMAT
	FROM USR.USRPackage
	WHERE UP_ID_USR = @UF_ID

	INSERT INTO @Updates(InfoBankId, Indx, Date, Docs, Kind, SysDate)
	SELECT I.UI_ID_BASE, U.UIU_INDX, UIU_DATE, UIU_DOCS, UIU_ID_KIND, UIU_SYS
	FROM USR.USRIB I
	INNER JOIN USR.USRUpdates U ON I.UI_ID = U.UIU_ID_IB
	WHERE I.UI_ID_USR = @UF_ID

	-- в список систем дотолкаем те, которые остутствуют судя по регузлу
	/*
	INSERT INTO @Systems(SystemId, Distr, Comp, IsExists)
	SELECT
	FROM 
	*/
	
	-- в список ИБ дотолкаем те, которые остусттвуют (судя по системам)
	INSERT INTO @Result(NAME, Service, Format, DataType)
	SELECT
		dbo.DistrString(S.SystemShortName, P.Distr, P.Comp) + 
		CASE P.Ric
			WHEN 20 THEN ''
			ELSE '/' + CONVERT(VARCHAR(20), P.Ric)
		END + '/' + 
		IsNUll(N.NT_SHORT, P.Tech + '/' + P.Net) + '/' + T.SST_SHORT + '/' + 
		CASE Service
			WHEN 0 THEN 'сопровождается'
			WHEN 1 THEN 'не сопровождается'
			ELSE 'не найден'
		END,
		R.Service,		
		P.Format,
		1
	FROM @Systems				P
	INNER JOIN dbo.SystemTable	S ON P.SystemId = S.SystemId
	OUTER APPLY
	(
		SELECT TOP 1 NT_SHORT
		FROM Din.NetType		N
		WHERE	N.NT_TECH_USR = P.Tech 
			AND N.NT_NET = P.Net
	) AS N
	LEFT JOIN Din.SystemType T ON T.SST_REG = P.Type
	CROSS APPLY Reg.DistrStatusGet(S.HostID, p.Distr, P.Comp, @UF_DATE) AS R;
	
	INSERT INTO @Result(NAME, Service, Format, DataType)
	SELECT
		dbo.DistrString(SystemShortName, DISTR, COMP) + '/' + NT_SHORT AS IB_NAME,
		-1 AS Service,		
		NULL AS UP_FORMAT,
		2 AS DATA_TYPE
	FROM 
		(
			SELECT DISTINCT Reg.RegComplectGet(HostID, Distr, Comp, @UF_DATE) AS COMPLECT
			FROM @Systems				P
			INNER JOIN dbo.SystemTable	S ON P.SystemId = S.SystemId
		) P
		CROSS APPLY
		(
			SELECT COMPLECT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_NET
			FROM Reg.ComplectStatusGet(@DS_ID, @UF_DATE) R
			WHERE R.COMPLECT = P.COMPLECT
		) R
		INNER JOIN dbo.SystemTable	S ON R.ID_SYSTEM = S.SystemID
		INNER JOIN Din.NetType		N ON R.ID_NET = N.NT_ID
	WHERE S.SystemBaseCheck = 1
		AND NOT EXISTS
		(
			SELECT *
			FROM @Systems E
			WHERE E.SystemId = S.SystemId
				AND E.Distr = R.DISTR
				AND E.Comp = R.COMP
		);
	
	SELECT *
	FROM @Result
END
