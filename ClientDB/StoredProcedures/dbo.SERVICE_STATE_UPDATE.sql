USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATE_UPDATE]
	@SERVICE	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NULL
	BEGIN
		EXEC dbo.SERVICE_STATE_REFRESH
		
		RETURN
	END

	DECLARE @STATE UNIQUEIDENTIFIER
	SET @STATE = NEWID()

	UPDATE dbo.ServiceState
	SET STATUS = 2
	WHERE STATUS = 1 AND ID_SERVICE = @SERVICE

	INSERT INTO dbo.ServiceState(ID, ID_SERVICE)
		SELECT @STATE, @SERVICE

	DECLARE @CUR_MONTH UNIQUEIDENTIFIER
	DECLARE @CUR_MONTH_BEGIN	SMALLDATETIME
	DECLARE @CUR_MONTH_END	SMALLDATETIME

	SELECT @CUR_MONTH = Common.PeriodCurrent(2)

	SELECT @CUR_MONTH_BEGIN = START, @CUR_MONTH_END = FINISH
	FROM Common.Period
	WHERE ID = @CUR_MONTH

	IF OBJECT_ID('tempdb..#cl_list') IS NOT NULL
		DROP TABLE #cl_list
		
	CREATE TABLE #cl_list
		(
			ClientID		INT PRIMARY KEY,
			ClientName		VARCHAR(512),
			ClientCom		BIT,
			ClientParent	INT
		)
		
	INSERT INTO #cl_list(ClientID, ClientName, ClientCom, ClientParent)
		SELECT ClientID, ClientFullName, ContractTypeHst, ID_HEAD
		FROM 
			dbo.ClientTable
			INNER JOIN dbo.ContractTypeTable ON ClientContractTypeID = ContractTypeID
		WHERE STATUS = 1 AND ClientServiceID = @SERVICE AND StatusID = 2
		
	-- 1. Не сообветствующие эталону ИБ

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, N'COMPLIANCE', ClientID, 
			REVERSE(STUFF(REVERSE(			
				(
					SELECT InfoBankShortName + ', '
					FROM
						USR.USRIBComplianceView z WITH(NOEXPAND)
						INNER JOIN dbo.InfoBankTable y ON z.UI_ID_BASE = y.InfoBankID
					WHERE z.UF_ID = c.UF_ID
					ORDER BY InfoBankOrder FOR XML PATH('')
				)), 1, 2, ''))
		FROM 
			#cl_list a
			INNER JOIN USR.USRComplianceView b WITH(NOEXPAND) ON a.ClientID = b.UD_ID_CLIENT
			INNER JOIN USR.USRActiveView c ON c.UF_ID = b.UF_ID
		WHERE UF_COMPLIANCE = '#HOST'

	-- 2. Старые технологические модули
		
	IF OBJECT_ID('tempdb..#res_check') IS NOT NULL
		DROP TABLE #res_check

	CREATE TABLE #res_check
		(
			ClientID		INT,
			ClientFullName	VARCHAR(512),
			ManagerName		VARCHAR(100),
			ServiceName		VARCHAR(100),
			UD_NAME			VARCHAR(50),
			ResVersionNum	VARCHAR(50),
			ConsVersionNum	VARCHAR(50),
			KDVersionNum	VARCHAR(50),
			UF_DATE			DATETIME,
			UF_CREATE		DATETIME
		)

	INSERT INTO #res_check
		EXEC USR.RES_VERSION_CHECK NULL, @SERVICE, null, null, 1, null, null, null

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT 
			@STATE, N'RES', ClientID, 
			'Комплект: ' + UD_NAME + 
				CASE ResVersionNum WHEN '' THEN '' ELSE '  ТМ: ' + ResVersionNum END +
				CASE ConsVersionNum WHEN '' THEN '' ELSE '  Cons.exe: ' + ConsVersionNum END
		FROM #res_check

	IF OBJECT_ID('tempdb..#res_check') IS NOT NULL
		DROP TABLE #res_check
		
	-- 3. Процент сбора СТТ
		
	IF OBJECT_ID('tempdb..#stt_check') IS NOT NULL
		DROP TABLE #stt_check
		
	CREATE TABLE #stt_check
		(
			ClientID	INT,
			ServiceName	VARCHAR(100),
			ManagerName	VARCHAR(100),
			STT_COUNT	INT,
			--USR_COUNT	INT,
			STT_CHECK	BIT
		)

	INSERT INTO #stt_check
		EXEC dbo.STT_TOTAL_REPORT @CUR_MONTH_BEGIN, @CUR_MONTH_END, @SERVICE, 1
		
	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'STT', ClientID, ''--'Кол-во файлов USR: ' + CONVERT(NVARCHAR(16), USR_COUNT)
		FROM #stt_check a
		WHERE STT_COUNT = 0-- AND USR_COUNT <> 0	
		
	IF OBJECT_ID('tempdb..#stt_check') IS NOT NULL
		DROP TABLE #stt_check
		
	-- 4. Неустановленные ИБ
		
	IF OBJECT_ID('tempdb..#ib_check') IS NOT NULL
		DROP TABLE #ib_check
		
	CREATE TABLE #ib_check
		(
			ClientID		INT,
			Manager			VARCHAR(100),
			Service			VARCHAR(100),
			ClientFullname	VARCHAR(500),
			Complect		VarChar(100),
			DisStr			VARCHAR(100),
			InfoBankShortName	VARCHAR(50),
			LAST_DATE	DATETIME,
			UF_DATE		DATETIME
		)
		
	INSERT INTO #ib_check
		EXEC USR.CLIENT_SYSTEM_AUDIT NULL, @SERVICE, NULL, NULL
		
	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'IB', ClientID,
			REVERSE(STUFF(REVERSE(
				(
					SELECT InfoBankShortName + ', '
					FROM #ib_check a
					WHERE a.ClientID = o_O.ClientID
					ORDER BY InfoBankShortName FOR XML PATH('')
				)), 1, 2, ''))
		FROM
			(
				SELECT DISTINCT ClientID
				FROM #ib_check
			) AS o_O
		
	IF OBJECT_ID('tempdb..#ib_check') IS NOT NULL
		DROP TABLE #ib_check
		
	-- 5. Должники
		
	IF OBJECT_ID('tempdb..#pay_check') IS NOT NULL
		DROP TABLE #pay_check

	CREATE TABLE #pay_check
		(
			RN	INT,
			ClientID	INT,
			ClientFullName VARCHAR(500),
			ServiceName		VARCHAR(100),
			PayType			VARCHAR(100),
			ContractPay		VARCHAR(100),
			PayDate			SMALLDATETIME,
			PAY				VARCHAR(50),
			PRC				FLOAT,
			LAST_PAY		SMALLDATETIME,
			PAY_DATES		VARCHAR(128),
			PAY_DELTA		INT,
			PAY_ERROR		INT,
			DistrStr		VARCHAR(100),
			PAY_DATE_ERRROR	INT,
			LAST_MON		SMALLDATETIME,
			LAST_ACT		SMALLDATETIME
		)

	INSERT INTO #pay_check	
		EXEC dbo.SERVICE_PAY_REPORT NULL, @SERVICE, @CUR_MONTH, NULL, NULL, NULL, NULL, NULL, NULL

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'PAY', ClientID, CONVERT(NVARCHAR(MAX), PRC)
			
		FROM #pay_check
		WHERE PAY <> 'Да'

	IF OBJECT_ID('tempdb..#pay_check') IS NOT NULL
		DROP TABLE #pay_check
		
	-- 6. Низкий процент сбора CFG

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'CFG', ClientID, ''
		FROM 
			#cl_list a
		WHERE /*ClientCom = 1
			AND	*/NOT EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientSearchTable z
				WHERE z.ClientID = a.ClientID
					AND SearchGetDay BETWEEN @CUR_MONTH_BEGIN AND @CUR_MONTH_END
			)
			AND
			(
				SELECT COUNT(*)
				FROM 
					USR.USRData z
					INNER JOIN USR.USRFile y ON UF_ID_COMPLECT = z.UD_ID
				WHERE z.UD_ID_CLIENT = a.ClientID
					AND UD_ACTIVE = 1
					AND UF_ACTIVE = 1
					AND (UF_PATH = 0 OR UF_PATH = 3)
					AND UF_DATE BETWEEN @CUR_MONTH_BEGIN AND @CUR_MONTH_END
			) > 0

	-- 7. Нет пополнений за 2 недели

	IF OBJECT_ID('tempdb..#update_check') IS NOT NULL
		DROP TABLE #update_check

	CREATE TABLE #update_check
		(
			ClientID		INT,
			ClientFullName	VARCHAR(512),
			UD_NAME			VARCHAR(100),
			ServiceName		VARCHAR(100),
			ManagerName		VARCHAR(100),
			LAST_UPDATE		DATETIME,
			EventComment	VARCHAR(MAX),
			PRIMARY KEY CLUSTERED (ClientID, UD_NAME)
		)	;

	INSERT INTO #update_check
		EXEC dbo.CLIENT_LAST_UPDATE_AUDIT @SERVICE, NULL, NULL

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'UPDATE', ClientID, CONVERT(NVARCHAR(20), LAST_UPDATE, 104)
		FROM #update_check

	IF OBJECT_ID('tempdb..#update_check') IS NOT NULL
		DROP TABLE #update_check

	-- 8. Кривые графики

	INSERT INTO dbo.ServiceStateDetail(ID_STATE, TP, ID_CLIENT, DETAIL)
		SELECT @STATE, 'GRAPH', ClientID, GR_ERROR
		FROM dbo.ClientGraphView
		WHERE ClientServiceID = @SERVICE AND GR_ERROR IS NOT NULL

	-- 9. Не записывали никого на семинары	

	
		
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END
