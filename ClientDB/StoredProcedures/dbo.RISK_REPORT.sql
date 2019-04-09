USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RISK_REPORT]
	@MANAGER	NVARCHAR(MAX),
	@SERVICE	SMALLINT,
	-- мин и макс кол-во проблем
	@TOTAL_B	SMALLINT,
	@TOTAL_E	SMALLINT,
	@TYPE		NVARCHAR(MAX),
	@AVG		NVARCHAR(16) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL
	
	-- за сколько месяцев считать среднее количество пользователей
	DECLARE @SEARCH_MON	SMALLINT
	-- минимальный порог для среднего количества
	DECLARE @SEARCH_CNT	SMALLINT
		
	-- за сколько месяцев считать звонки в ДС
	DECLARE @DUTY_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @DUTY_CNT	SMALLINT

	-- за сколько месяцев считать конкурентов
	DECLARE @RIVAL_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @RIVAL_CNT	SMALLINT

	-- за сколько недель считать пополнения
	DECLARE @UPD_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @UPD_CNT	SMALLINT

	-- за сколько недель считать контрольные пополнения и пополнения руками
	DECLARE @CONTROL_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @CONTROL_CNT	SMALLINT

	-- за сколько месяцев считать обучение
	DECLARE @STUDY_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @STUDY_CNT	SMALLINT

	-- за сколько месяцев считать семинары
	DECLARE @SEMINAR_MON	SMALLINT
	-- минимальный порог для количества
	DECLARE @SEMINAR_CNT	SMALLINT

	SELECT 
		@SEARCH_MON = SEARCH_MON, @SEARCH_CNT = SEARCH_CNT,
		@DUTY_MON = DUTY_MON, @DUTY_CNT = DUTY_CNT,
		@RIVAL_MON = RIVAL_MON, @RIVAL_CNT = RIVAL_CNT,
		@UPD_MON = UPD_WEEK, @UPD_CNT = UPD_CNT,
		--@CONTROL_MON	@CONTROL_CNT	
		@STUDY_MON = STUDY_MON, @STUDY_CNT = STUDY_CNT,
		@SEMINAR_MON = SEMINAR_MON, @SEMINAR_CNT = SEMINAR_CNT
	FROM dbo.Risk
	WHERE STATUS = 1

	DECLARE @MON	SMALLDATETIME

	SET @MON = dbo.MonthOf(GETDATE())

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	CREATE TABLE #client
		(
			ClientID	INT PRIMARY KEY,
			USR_CNT		INT,
			SEARCH		BIT,
			SEARCH_AVG	DECIMAL(8, 2),
			DUTY		BIT,
			DUTY_CNT	SMALLINT,
			RIVAL		BIT,
			RIVAL_CNT	SMALLINT,
			UPDATES		BIT,
			UPDATES_CNT	SMALLINT,
			CONTROL		BIT,
			CONTROL_CNT	SMALLINT,
			STUDY		BIT,
			STUDY_CNT	SMALLINT,
			SEMINAR		BIT,
			SEMINAR_CNT	SMALLINT,
			ERR_CNT		SMALLINT
		)
		
	DECLARE @BEGIN	SMALLDATETIME
	DECLARE @END	SMALLDATETIME
	
	SET @BEGIN = DATEADD(MONTH, -1, dbo.MonthOf(GETDATE()))
	SET @END = DATEADD(DAY, -1, DATEADD(MONTH, 1, dbo.MonthOf(GETDATE())))
		
	INSERT INTO #client(ClientID, USR_CNT)
		SELECT 
			a.ClientID,
			(
				SELECT COUNT(*)
				FROM 
					USR.USRData z
					INNER JOIN USR.USRFile y ON UF_ID_COMPLECT = z.UD_ID
				WHERE z.UD_ID_CLIENT = a.ClientID
					AND UD_ACTIVE = 1
					AND UF_ACTIVE = 1
					AND (UF_PATH = 0 OR UF_PATH = 3)
					AND UF_DATE BETWEEN @BEGIN AND @END
			)
		FROM 
			dbo.ClientView AS a WITH(NOEXPAND)
			INNER JOIN dbo.ClientTable AS b ON a.ClientID = b.ClientID
		WHERE ServiceStatusID = 2
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
			AND (b.ClientContractTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)) OR @TYPE IS NULL)
		
	UPDATE a
	SET SEARCH_AVG = AVG_CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT ClientID, AVG(CNT) AS AVG_CNT
				FROM
					(
						SELECT a.ClientID, a.START, CONVERT(DECIMAL(8, 2), ISNULL(CNT, 0)) AS CNT
						FROM 
							(
								SELECT a.START, b.ClientID
								FROM Common.Period a CROSS JOIN #client b 
								WHERE a.START BETWEEN DATEADD(MONTH, -@SEARCH_MON, @MON) AND DATEADD(MONTH, -@SEARCH_MON + 1, @MON) AND a.TYPE = 2
							) AS a	
							LEFT OUTER JOIN dbo.ClientSearchView b WITH(NOEXPAND) ON a.START = b.SearchMonthDate AND b.ClientID = a.ClientID
					) AS o_O
				GROUP BY ClientID
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET SEARCH = CASE WHEN SEARCH_AVG < @SEARCH_CNT THEN 1 ELSE 0 END
		
	UPDATE a
	SET DUTY_CNT = CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT ClientID, COUNT(*) AS CNT
				FROM dbo.ClientDutyTable
				WHERE STATUS = 1 AND ClientDutyDateTime BETWEEN DATEADD(MONTH, -@DUTY_MON, GETDATE()) AND GETDATE()
				GROUP BY ClientID			
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET DUTY_CNT = ISNULL(DUTY_CNT, 0)
		
	UPDATE #client
	SET DUTY = CASE WHEN DUTY_CNT < @DUTY_CNT THEN 1 ELSE 0 END

	UPDATE a
	SET RIVAL_CNT = CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT CL_ID AS ClientID, COUNT(*) AS CNT
				FROM dbo.ClientRival
				WHERE CR_ACTIVE = 1 AND CR_DATE BETWEEN DATEADD(MONTH, -@RIVAL_MON, GETDATE()) AND GETDATE()
				GROUP BY CL_ID
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET RIVAL_CNT = ISNULL(RIVAL_CNT, 0)
		
	UPDATE #client
	SET RIVAL = CASE WHEN RIVAL_CNT >= @RIVAL_CNT THEN 1 ELSE 0 END

	UPDATE a
	SET STUDY_CNT = CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT ID_CLIENT AS ClientID, COUNT(*) AS CNT
				FROM dbo.ClientStudy
				WHERE STATUS = 1 AND DATE BETWEEN DATEADD(MONTH, -@STUDY_MON, GETDATE()) AND GETDATE() AND ID_PLACE IN (1, 2) AND TEACHED = 1
				GROUP BY ID_CLIENT
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET STUDY_CNT = ISNULL(STUDY_CNT, 0)
		
	UPDATE #client
	SET STUDY = CASE WHEN STUDY_CNT < @STUDY_CNT THEN 1 ELSE 0 END

	UPDATE a
	SET SEMINAR_CNT = CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT ID_CLIENT AS ClientID, COUNT(*) AS CNT
				FROM dbo.ClientStudy
				WHERE STATUS = 1 AND DATE BETWEEN DATEADD(MONTH, -@SEMINAR_MON, GETDATE()) AND GETDATE() AND ID_PLACE IN (3, 4, 5) AND TEACHED = 1
				GROUP BY ID_CLIENT
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET SEMINAR_CNT = ISNULL(SEMINAR_CNT, 0)
		
	UPDATE #client
	SET SEMINAR = CASE WHEN SEMINAR_CNT < @SEMINAR_CNT THEN 1 ELSE 0 END

	UPDATE a
	SET UPDATES_CNT = CNT
	FROM 
		#client a
		INNER JOIN
			(
				SELECT UD_ID_CLIENT AS ClientID, COUNT(CNT) AS CNT
				FROM
					(
						SELECT UD_ID_CLIENT, START, FINISH, COUNT(*) AS CNT
						FROM
							(		
								SELECT START, FINISH
								FROM 
									(
										SELECT START, FINISH, ROW_NUMBER() OVER(ORDER BY START DESC) AS RN
										FROM Common.Period
										WHERE TYPE = 1 AND START <= DATEADD(WEEK, -1, GETDATE())
									) AS a				
								WHERE RN <= @UPD_MON
							) AS a
							INNER JOIN USR.USRDateKindView AS b WITH(NOEXPAND) ON UIU_DATE_S BETWEEN START AND FINISH
						GROUP BY UD_ID_CLIENT, START, FINISH
					) AS o_O
				GROUP BY UD_ID_CLIENT
			) AS b ON a.ClientID = b.ClientID
		
	UPDATE #client
	SET UPDATES_CNT = ISNULL(UPDATES_CNT, 0)
		
	UPDATE #client
	SET UPDATES = CASE WHEN UPDATES_CNT < @UPD_CNT THEN 1 ELSE 0 END

	UPDATE #client
	SET ERR_CNT = CONVERT(SMALLINT, SEARCH) + CONVERT(SMALLINT, DUTY) + CONVERT(SMALLINT, RIVAL) + CONVERT(SMALLINT, UPDATES) + CONVERT(SMALLINT, STUDY) + CONVERT(SMALLINT, SEMINAR)
		
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY ManagerName, ServiceName ORDER BY ManagerName, ServiceName, ClientFullName) AS RN,
		a.ClientID, ClientFullName, USR_CNT, c.ServiceTypeShortName, ServiceName, ManagerName,
		SEARCH, SEARCH_AVG, DUTY, DUTY_CNT, RIVAL, RIVAL_CNT,
		UPDATES, UPDATES_CNT, STUDY, STUDY_CNT, SEMINAR, SEMINAR_CNT,
		ERR_CNT,
		CONVERT(NVARCHAR(32), @SEARCH_MON) + ' мес.' AS SEARCH_PARAM,
		CONVERT(NVARCHAR(32), @DUTY_MON) + ' мес.' AS DUTY_PARAM,
		CONVERT(NVARCHAR(32), @RIVAL_MON) + ' мес.' AS RIVAL_PARAM,
		CONVERT(NVARCHAR(32), @UPD_MON) + ' нед.' AS UPDATE_PARAM,
		CONVERT(NVARCHAR(32), @STUDY_MON) + ' мес.' AS STUDY_PARAM,
		CONVERT(NVARCHAR(32), @SEMINAR_MON) + ' мес.' AS SEMINAR_PARAM
		/*,
		REVERSE(STUFF(REVERSE(RTRIM((
			SELECT CONVERT(VARCHAR(20), ERR_CNT) + ': ' + CONVERT(VARCHAR(20), CNT) + ',    '
			FROM
				(
					SELECT ERR_CNT, COUNT(*) AS CNT
					FROM #client z INNER JOIN dbo.ClientView y WITH(NOEXPAND) ON z.ClientID = y.ClientID
					WHERE y.ServiceName = b.ServiceName
					GROUP BY ERR_CNT
				) AS o_O
			ORDER BY CNT DESC FOR XML PATH('')
		))), 1, 1, '')) AS ERR_TOTAL*/
	FROM 
		#client a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		INNER JOIN dbo.ServiceTypeTable c ON c.ServiceTypeID = b.ServiceTypeID
	WHERE (ERR_CNT >= @TOTAL_B OR @TOTAL_B IS NULL)
		AND (ERR_CNT <= @TOTAL_E OR @TOTAL_E IS NULL)
	ORDER BY ManagerName, ServiceName
		
	SELECT @AVG = CONVERT(NVARCHAR(16), ROUND(AVG(CONVERT(FLOAT, ERR_CNT)), 2))
	FROM #client
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END
