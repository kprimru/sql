USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LARGE_REPORT]
	@SERVICE	INT,
	@MANAGER	NVARCHAR(MAX),
	@CLIENT		NVARCHAR(256),
	@EVENT_CNT	INT,
	@RIVAL_CNT	INT
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL
			
		IF @EVENT_CNT IS NULL
			SET @EVENT_CNT = 1
			
		IF @RIVAL_CNT IS NULL
			SET @RIVAL_CNT = 1

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID		INT,
				ManagerName		NVARCHAR(128),
				ServiceName		NVARCHAR(128),
				ClientFullName	NVARCHAR(512),
				DistrStr		NVARCHAR(128),
				ConnectDate		SMALLDATETIME,
				STUDY_COUNT		INT,
				DUTY_COUNT		INT,
				CL_ROW			INT,
				RN				INT,
				TENDER			NVARCHAR(MAX),
				EventDate		SMALLDATETIME,
				EventCreate		NVARCHAR(128),
				EventComment	NVARCHAR(MAX),
				/*
				CPT_NAME		NVARCHAR(128),
				CP_FIO			NVARCHAR(256),
				CP_POS			NVARCHAR(128),
				CP_NOTE			NVARCHAR(MAX),
				CP_PHONE		NVARCHAR(128),
				CP_EMAIL		NVARCHAR(128),
				*/
				CR_DATE			SMALLDATETIME,
				CR_CONDITION	NVARCHAR(MAX),
				RivalTypeName	NVARCHAR(128),
				DATE			SMALLDATETIME,
				PERSONAL		NVARCHAR(128),
				NOTE			NVARCHAR(MAX)
			)
		
		INSERT INTO #client(ClientID, ManagerName, ServiceName, ClientFullName, DistrStr, ConnectDate, STUDY_COUNT, DUTY_COUNT, CL_ROW, RN)
			SELECT 
				ClientID, ManagerName, ServiceName, ClientFullName, 
				(
					SELECT TOP 1 DistrStr + ' (' + DistrTypeName + ')'
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = a.ClientID
						AND DS_REG = 0
						/*
						AND SystemTypeName IN ('Серия А', 'коммерческая', 'Серия К')
						AND 
							(
								z.HostID = 1
								AND 
								z.DistrTypeName IN ('сеть', 'м/с')
									
								OR
									
								z.DistrTypeName = '1/с'
								AND
								z.SystemBaseName IN ('LAW', 'BVP', 'BUDP', 'JURP')
							)
						*/
					ORDER BY SystemOrder
				) AS DISTR_STR, 
				ConnectDate,			
				(
					SELECT COUNT(*)
					FROM dbo.CLientStudy z
					WHERE STATUS = 1
						AND z.ID_CLIENT = a.ClientID
						AND DATEPART(YEAR, z.DATE) IN (DATEPART(YEAR, GETDATE()), DATEPART(YEAR, GETDATE()) - 1)
				) AS STUDY_COUNT,
				(
					SELECT COUNT(*)
					FROM dbo.ClientDutyTable z
					WHERE z.ClientID = a.ClientID
						AND z.STATUS = 1
						AND z.ClientDutyDateTime >= DATEADD(MONTH, -3, GETDATE())
				) AS DUTY_COUNT,
				CL_ROW, num.ID
			FROM 
				(
					SELECT a.ClientID, ClientFullName, a.ServiceStatusID, ServiceID, ManagerID, ManagerName, ServiceName, ConnectDate,
						(
							SELECT MAX(CL_ROW)
							FROM
								(
									/*
									SELECT COUNT(*) AS CL_ROW
									FROM dbo.ClientPersonal
									WHERE CP_ID_CLIENT = a.ClientID
									
									UNION ALL
									*/
										
									SELECT @EVENT_CNT AS CL_ROW
										
									UNION ALL
										
									SELECT @RIVAL_CNT
									
									UNION ALL
									
									SELECT COUNT(*)
									FROM dbo.ClientContact z
									WHERE z.ID_CLIENT = a.ClientID
										AND z.STATUS = 1
								) AS o_O
						) AS CL_ROW
					FROM 
						dbo.ClientView a WITH(NOEXPAND)
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
						LEFT OUTER JOIN
							(
								SELECT ClientID, MIN(ConnectDate) AS ConnectDate
								FROM dbo.ClientConnectView WITH(NOEXPAND)
								GROUP BY ClientID				
							) AS b ON a.ClientID = b.ClientID
					WHERE	(a.ServiceID = @SERVICE OR @SERVICE IS NULL)
						AND (a.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
						AND (a.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
						
						AND a.ClientID IN
							(
								SELECT ClientID
								FROM dbo.ClientLargeView
							)
							
						/*	
						AND EXISTS
							(
								SELECT *
								FROM dbo.ClientDistrView z WITH(NOEXPAND)
								WHERE z.ID_CLIENT = a.ClientID
									AND DS_REG = 0
									AND SystemTypeName IN ('Серия А', 'коммерческая', 'Серия К')
									AND 
										(
											z.HostID = 1
											AND 
											z.DistrTypeName IN ('сеть', 'м/с')
											
											OR
											
											z.DistrTypeName = '1/с'
											AND
											z.SystemBaseName IN ('LAW', 'BVP', 'BUDP', 'JURP')
										)
							)
							*/
				) AS a
				CROSS APPLY
					(
						SELECT ID
						FROM dbo.Numbers z
						WHERE z.ID <= CL_ROW
					) AS num			
			ORDER BY ManagerName, ServiceName, ClientFullName, num.ID

		UPDATE a
		SET a.EventDate		= b.EventDate,
			a.EventCreate	= b.EventCreateUser,
			a.EventComment	= b.EventComment
		FROM
			#client a
			CROSS APPLY
				(
					SELECT RN, EventDate, EventCreateUser, EventComment
					FROM
						(
							SELECT ROW_NUMBER() OVER(ORDER BY EventDate DESC) AS RN, EventDate, EventCreateUser, EventComment
							FROM dbo.EventTable z
							WHERE z.ClientID = a.ClientID
								AND EventActive = 1
								AND EventCreateUser IN
									(
										SELECT ServiceLogin
										FROM dbo.ServiceTable
										WHERE ServiceDismiss IS NULL
									)
						) AS o_O
					WHERE RN <= @EVENT_CNT
				) AS b
			WHERE a.RN = b.RN
			
		/*
		UPDATE a
		SET a.CPT_NAME	=	b.CPT_SHORT,
			a.CP_FIO	=	b.CP_FIO,
			a.CP_POS	=	b.CP_POS,
			a.CP_NOTE	=	b.CP_NOTE,
			a.CP_PHONE	=	b.CP_PHONE,
			a.CP_EMAIL	=	b.CP_EMAIL
		FROM
			#client a
			CROSS APPLY
				(
					SELECT 
						ROW_NUMBER() OVER(ORDER BY ISNULL(CPT_REQUIRED, 0) DESC, CPT_ORDER, CP_SURNAME) AS RN,
						CPT_SHORT,
						CASE ISNULL(CP_SURNAME, '')
							WHEN '' THEN ''
							ELSE CP_SURNAME + ' '
						END + 		
						CASE ISNULL(CP_NAME, '')	
							WHEN '' THEN ''
							ELSE CP_NAME + ' '
						END +
						ISNULL(CP_PATRON, '') AS CP_FIO,
						CP_POS, CP_NOTE, CP_PHONE, CP_EMAIL,
						CPT_REQUIRED, CPT_ORDER
					FROM
						dbo.ClientPersonal
						LEFT OUTER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
					WHERE CP_ID_CLIENT = a.ClientID
				) AS b
			WHERE a.RN = b.RN
			*/
			
			
		UPDATE a
		SET a.CR_DATE		= b.CR_DATE,
			a.CR_CONDITION	= b.CR_CONDITION,
			a.RivalTypeName	= b.RivalTypeName
		FROM
			#client a
			CROSS APPLY
				(
					SELECT RN, CR_DATE, CR_CONDITION, RivalTypeName
					FROM
						(
							SELECT ROW_NUMBER() OVER(ORDER BY CR_DATE DESC) AS RN, CR_DATE, CR_CONDITION, RivalTypeName
							FROM 
								dbo.ClientRival z
								INNER JOIN dbo.RivalTypeTable y ON z.CR_ID_TYPE = y.RivalTypeID
							WHERE CL_ID = a.ClientID
								AND CR_ACTIVE = 1
						) AS o_O
					WHERE RN <= @RIVAL_CNT
				) AS b
			WHERE a.RN = b.RN

		UPDATE a
		SET a.DATE		= b.DATE,
			a.PERSONAL	= b.PERSONAL,
			a.NOTE		= b.NOTE
		FROM
			#client a
			CROSS APPLY
				(
					SELECT ROW_NUMBER() OVER(ORDER BY DATE DESC) AS RN, DATE, PERSONAL, NOTE
					FROM dbo.ClientContact z
					WHERE z.ID_CLIENT = a.ClientID
						AND z.STATUS = 1
				) AS b
			WHERE a.RN = b.RN
			

		SELECT *
		FROM #client
		ORDER BY ManagerName, ServiceName, ClientFullName, RN

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
