USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT_FILTER2]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@REASON		UNIQUEIDENTIFIER,
	@MANAGER	INT,
	@SERVICE	INT,
	@OPER		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SET @END = DATEADD(DAY, 1, @END)

	/*
	найти дистрибутиыы, которые были отключены в данный промежуток времени
	*/

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

	CREATE TABLE #distr
		(
			DATE	SMALLDATETIME,
			ID_HOST	SMALLINT,
			DISTR	INT,
			COMP	TINYINT
		)

	IF @OPER = 1
		INSERT INTO #distr(ID_HOST, DISTR, COMP, DATE)
			SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
			FROM 
				dbo.RegProtocol
				INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
			WHERE (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (RPR_DATE < @END OR @END IS NULL)
				AND RPR_OPER IN ('Включение', 'Сопровождение подключено')
				AND HostReg = 'LAW'
	ELSE IF @OPER = 2
		INSERT INTO #distr(ID_HOST, DISTR, COMP, DATE)
			SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
			FROM 
				dbo.RegProtocol
				INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
			WHERE (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (RPR_DATE < @END OR @END IS NULL)
				AND RPR_OPER IN ('Новая')
				AND HostReg = 'LAW'
	ELSE
		INSERT INTO #distr(ID_HOST, DISTR, COMP, DATE)
			SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
			FROM 
				dbo.RegProtocol
				INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
			WHERE (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (RPR_DATE < @END OR @END IS NULL)
				AND RPR_OPER IN ('Отключение', 'Сопровождение отключено')
				AND HostReg = 'LAW'
		 
	DELETE
	FROM #distr
	WHERE EXISTS
		(
			SELECT *
			FROM 
				dbo.RegNodeTable a
				INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
				INNER JOIN Din.SystemType c ON c.SST_REG = a.DistrType
			WHERE DistrNumber = DISTR AND CompNumber = COMP AND HostID = ID_HOST AND SST_WEIGHT = 0
		)
		 
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result	
		 
	SELECT 
		ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
		DATE AS CD_DATE, DR_NAME, CD_NOTE,
		dbo.DistrWeight(SystemID, DistrTypeID, SystemTypeName, DATE) AS WEIGHT
	INTO #result
	FROM 
		#distr a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.ID_HOST = b.HostID
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		OUTER APPLY
			(
				SELECT TOP 1 CD_DATE, DR_NAME, CD_NOTE, DR_ID
				FROM 
					dbo.ClientDisconnect
					LEFT OUTER JOIN dbo.DisconnectReason ON CD_ID_REASON = DR_ID
				WHERE CD_TYPE = 1 AND CD_ID_CLIENT = ClientID
					AND (@OPER = 0 OR @OPER IS NULL)
				ORDER BY CD_DATE DESC, CD_DATETIME DESC
			) d --ON CD_ID_CLIENT = ClientID
	WHERE (@OPER = 2 OR @OPER = 1 OR (DR_ID = @REASON OR @REASON IS NULL) AND (@OPER = 0 OR @OPER IS NULL))
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
	ORDER BY CD_DATE DESC, ManagerName, ServiceName, SystemOrder

	SELECT 
		ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
		CD_DATE, DR_NAME, CD_NOTE, WEIGHT
	FROM #result
	ORDER BY CD_DATE DESC, ManagerName, ServiceName
	
		 
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
END
