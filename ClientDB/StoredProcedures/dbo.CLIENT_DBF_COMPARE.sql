USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DBF_COMPARE]
	@MANAGER	INT,
	@SERVICE	INT,
	@TYPE		NVARCHAR(MAX)
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

		DECLARE @SQL NVARCHAR(MAX)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		DECLARE @TP	TABLE (TP_NAME NVARCHAR(512))
		
		INSERT INTO @TP(TP_NAME)
			SELECT ID
			FROM dbo.TableStringFromXML(@TYPE)
			
		DECLARE @NAME		BIT
		DECLARE @ADDRESS	BIT
		DECLARE	@DIR_FIO	BIT
		DECLARE @DIR_POS	BIT
		DECLARE @DIR_PHONE	BIT
		DECLARE	@BUH_FIO	BIT
		DECLARE @BUH_POS	BIT
		DECLARE @BUH_PHONE	BIT
		DECLARE	@RES_FIO	BIT
		DECLARE @RES_POS	BIT
		DECLARE @RES_PHONE	BIT
		DECLARE @SRVC		BIT		
		DECLARE @INN		BIT
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'ФИО руководителя'
			)
			SET @DIR_FIO = 1
		ELSE
			SET @DIR_FIO = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'ФИО гл.бух'
			)
			SET @BUH_FIO = 1
		ELSE
			SET @BUH_FIO = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'ФИО ответственного'
			)
			SET @RES_FIO = 1
		ELSE
			SET @RES_FIO = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Должность руководителя'
			)
			SET @DIR_POS = 1
		ELSE
			SET @DIR_POS = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Должность гл.бух'
			)
			SET @BUH_POS = 1
		ELSE
			SET @BUH_POS = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Должность ответственного'
			)
			SET @RES_POS = 1
		ELSE
			SET @RES_POS = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Телефон руководителя'
			)
			SET @DIR_PHONE = 1
		ELSE
			SET @DIR_PHONE = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Телефон гл.бух'
			)
			SET @BUH_PHONE = 1
		ELSE
			SET @BUH_PHONE = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Телефон ответственного'
			)
			SET @RES_PHONE = 1
		ELSE
			SET @RES_PHONE = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Адрес'
			)
			SET @ADDRESS = 1
		ELSE
			SET @ADDRESS = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Название'
			)
			SET @NAME = 1
		ELSE
			SET @NAME = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'Сервис-инженер'
			)
			SET @SRVC = 1
		ELSE
			SET @SRVC = 0
			
		IF EXISTS
			(
				SELECT *
				FROM @TP
				WHERE TP_NAME = 'ИНН'
			)
			SET @INN = 1
		ELSE
			SET @INN = 0
			
		/*SELECT @ADDRESS, @DIR_FIO, @DIR_POS, @DIR_PHONE, @BUH_FIO, @BUH_POS, @BUH_PHONE, @RES_FIO, @RES_POS, @RES_PHONE, @SRVC*/
			
		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client
			
		CREATE TABLE #client
			(
				ClientID		INT PRIMARY KEY,
				DIR_FIO			VARCHAR(250),
				DIR_SURNAME		VARCHAR(250),
				DIR_NAME		VARCHAR(250),
				DIR_PATRON		VARCHAR(250),
				DIR_FIO_LAST	DATETIME,
				DIR_POS			VARCHAR(250),
				DIR_POS_LAST	DATETIME,
				DIR_PHONE		VARCHAR(250),
				DIR_PHONE_LAST	DATETIME,
				BUH_FIO			VARCHAR(250),
				BUH_SURNAME		VARCHAR(250),
				BUH_NAME		VARCHAR(250),
				BUH_PATRON		VARCHAR(250),
				BUH_FIO_LAST	DATETIME,
				BUH_POS			VARCHAR(250),
				BUH_POS_LAST	DATETIME,
				BUH_PHONE		VARCHAR(250),
				BUH_PHONE_LAST	DATETIME,
				RES_FIO			VARCHAR(250),			
				RES_SURNAME		VARCHAR(250),
				RES_NAME		VARCHAR(250),
				RES_PATRON		VARCHAR(250),
				RES_FIO_LAST	DATETIME,
				RES_POS			VARCHAR(250),
				RES_POS_LAST	DATETIME,
				RES_PHONE		VARCHAR(250),
				RES_PHONE_LAST	DATETIME,			
				SERVICE			VARCHAR(250),
				CITY_PARENT		VARCHAR(250),
				CITY			VARCHAR(250),
				PREFIX			VARCHAR(50),
				STREET			VARCHAR(250),
				HOME			VARCHAR(150),
				OFFICE			VARCHAR(150),
				ADDRESS_LAST	DATETIME,
				INN				VARCHAR(50),
				CLientFullName	VarCHar(500)
			)
			
		INSERT INTO #client(ClientID)
			SELECT ClientID
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE	(ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			
		IF OBJECT_ID('tempdb..#client_dbf') IS NOT NULL
			DROP TABLE #client_dbf

		CREATE TABLE #client_dbf
			(
				ClientID	INT NOT NULL,
				TO_ID		INT NOT NULL,
				DISTR		VARCHAR(50),
				DISTR_DBF	VARCHAR(50)
			)	
			
		INSERT INTO #client_dbf(ClientID, TO_ID, DISTR, DISTR_DBF)
			SELECT o_O.ClientID, o_O.TD_ID_TO,
				(
					SELECT TOP 1 DistrStr
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = o_O.ClientID
						AND DS_REG = 0
					ORDER BY SystemOrder
				) AS DISTR,
				(
					SELECT TOP 1 DIS_STR
					FROM
						[PC275-SQL\DELTA].DBF.dbo.DistrView z
						INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TODistrTable y ON z.DIS_ID = y.TD_ID_DISTR
						INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeTable ON SYS_REG_NAME = RN_SYS_NAME
												AND DIS_NUM = RN_DISTR_NUM
												AND DIS_COMP_NUM = RN_COMP_NUM 						
					WHERE y.TD_ID_TO = o_O.TD_ID_TO AND RN_SERVICE = 0
					ORDER BY SYS_ORDER
				) AS DISTR_DBF
			FROM
				(
					SELECT DISTINCT a.ClientID, e.TD_ID_TO
					FROM
						#client a
						INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.ID_CLIENT = a.ClientID
						INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrView d ON d.SYS_REG_NAME = c.SystemBaseName
																			AND d.DIS_NUM = c.DISTR
																			AND d.DIS_COMP_NUM = c.COMP
						INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TODistrTable e ON e.TD_ID_DISTR = d.DIS_ID
						INNER JOIN Reg.RegNodeSearchView f WITH(NOEXPAND) ON f.SystemBaseName = c.SystemBaseName AND f.DistrNumber = c.DISTR AND f.CompNumber = c.COMP
					WHERE f.Service = 0
				) AS o_O
			
		SET @SQL = 'ALTER TABLE #client_dbf ADD CONSTRAINT [' + CONVERT(NVARCHAR(128), NEWID()) + '] PRIMARY KEY CLUSTERED 
			(
				ClientID,
				TO_ID
			) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)'
		EXEC (@SQL)	
			
		IF OBJECT_ID('tempdb..#dbf') IS NOT NULL
			DROP TABLE #dbf
			
		CREATE TABLE #dbf
			(
				TO_ID			INT PRIMARY KEY,
				DIR_FIO			VARCHAR(250),
				DIR_SURNAME		VARCHAR(250),
				DIR_NAME		VARCHAR(250),
				DIR_PATRON		VARCHAR(250),
				DIR_POS			VARCHAR(250),
				DIR_PHONE		VARCHAR(250),
				DIR_LAST		DATETIME,
				BUH_FIO			VARCHAR(250),
				BUH_SURNAME		VARCHAR(250),
				BUH_NAME		VARCHAR(250),
				BUH_PATRON		VARCHAR(250),
				BUH_POS			VARCHAR(250),
				BUH_PHONE		VARCHAR(250),
				BUH_LAST		DATETIME,
				RES_FIO			VARCHAR(250),
				RES_SURNAME		VARCHAR(250),
				RES_NAME		VARCHAR(250),
				RES_PATRON		VARCHAR(250),
				RES_POS			VARCHAR(250),
				RES_PHONE		VARCHAR(250),
				RES_LAST		DATETIME,
				SERVICE			VARCHAR(250),
				CITY			VARCHAR(250),
				STREET			VARCHAR(250),
				HOME			VARCHAR(150),
				ADDRESS_LAST	DATETIME,
				INN				VARCHAR(50),
				TO_NAME			VarChar(500)
			)
			
		INSERT INTO #dbf(TO_ID)
			SELECT DISTINCT TO_ID
			FROM #client_dbf
			
		/*
			заполнение данных адресов и сотрудников, которые выбраны
		*/
		IF @DIR_FIO = 1 OR @DIR_POS = 1 OR @DIR_PHONE = 1
		BEGIN
			UPDATE a
			SET DIR_FIO = CP_FIO,
				DIR_SURNAME = REPLACE(CP_SURNAME, 'ё', 'е'),
				DIR_NAME = REPLACE(CP_NAME, 'ё', 'е'),
				DIR_PATRON = REPLACE(CP_PATRON, 'ё', 'е'),
				DIR_POS = CP_POS,
				DIR_PHONE = CP_PHONE
				,
				DIR_FIO_LAST = L.ClientLast,
				DIR_POS_LAST = L.ClientLast,
				DIR_PHONE_LAST = L.ClientLast
				/*
				DIR_FIO_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalDirLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND 
									(
										z.CP_SURNAME <> b.CP_SURNAME
										OR z.CP_NAME <> b.CP_NAME
										OR z.CP_PATRON <> b.CP_PATRON
									)
							ORDER BY ClientLast DESC
						),
				DIR_POS_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalDirLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_POS <> b.CP_POS
							ORDER BY ClientLast DESC
						),
				DIR_PHONE_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalDirLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_PHONE <> b.CP_PHONE
							ORDER BY ClientLast DESC
						)
				*/
			FROM 
				#client a
				INNER JOIN dbo.ClientPersonalDirView b WITH(NOEXPAND) ON a.ClientID = b.CP_ID_CLIENT
				OUTER APPLY
				(
					SELECT TOP 1 ClientLast
					FROM dbo.ClientPersonalDirLastView z
					WHERE a.ClientID = z.ID_MASTER
						AND 
						(
							z.CP_SURNAME <> b.CP_SURNAME
							OR 
							z.CP_NAME <> b.CP_NAME
							OR 
							z.CP_PATRON <> b.CP_PATRON
							OR
							z.CP_POS <> b.CP_POS
							OR
							z.CP_PHONE <> b.CP_PHONE
						)
					ORDER BY ClientLast DESC
				) L
				
			UPDATE a
			SET DIR_FIO = ISNULL(TP_SURNAME + ' ', '') + ISNULL(TP_NAME + ' ', '') + ISNULL(TP_OTCH, ''),
				DIR_SURNAME = REPLACE(TP_SURNAME, 'ё', 'е'),
				DIR_NAME = REPLACE(TP_NAME, 'ё', 'е'),
				DIR_PATRON = REPLACE(TP_OTCH, 'ё', 'е'),
				DIR_POS = POS_NAME,
				DIR_PHONE = TP_PHONE,
				DIR_LAST = TP_LAST
			FROM 
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.TOPersonalTable b ON b.TP_ID_TO = a.TO_ID
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.PositionTable c ON c.POS_ID = b.TP_ID_POS
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ReportPositionTable g ON g.RP_ID = b.TP_ID_RP AND g.RP_PSEDO = 'LEAD'
		
			IF @DIR_PHONE = 1
			BEGIN
				UPDATE #client
				SET DIR_PHONE = dbo.PhoneString(DIR_PHONE)
				
				UPDATE #dbf
				SET DIR_PHONE = dbo.PhoneString(DIR_PHONE)
			END
		END
		
		IF @BUH_FIO = 1 OR @BUH_POS = 1 OR @BUH_PHONE = 1
		BEGIN
			UPDATE a
			SET BUH_FIO = CP_FIO,
				BUH_SURNAME = REPLACE(CP_SURNAME, 'ё', 'е'),
				BUH_NAME = REPLACE(CP_NAME, 'ё', 'е'),
				BUH_PATRON = REPLACE(CP_PATRON, 'ё', 'е'),
				BUH_POS = CP_POS,
				BUH_PHONE = CP_PHONE
				,	
				BUH_FIO_LAST = L.ClientLast,
				BUH_POS_LAST = L.ClientLast,
				BUH_PHONE_LAST = L.ClientLast
				/*		
				BUH_FIO_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalBuhLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND 
									(
										z.CP_SURNAME <> b.CP_SURNAME
										OR z.CP_NAME <> b.CP_NAME
										OR z.CP_PATRON <> b.CP_PATRON
									)
							ORDER BY ClientLast DESC
						),
				BUH_POS_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalBuhLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_POS <> b.CP_POS
							ORDER BY ClientLast DESC
						),
				BUH_PHONE_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalBuhLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_PHONE <> b.CP_PHONE
							ORDER BY ClientLast DESC
						)
						*/
				
			FROM 
				#client a
				INNER JOIN dbo.ClientPersonalBuhView b WITH(NOEXPAND) ON a.ClientID = b.CP_ID_CLIENT
				OUTER APPLY
				(
					SELECT TOP 1 ClientLast
					FROM dbo.ClientPersonalBuhLastView z
					WHERE a.ClientID = z.ID_MASTER
						AND 
						(
							z.CP_SURNAME <> b.CP_SURNAME
							OR 
							z.CP_NAME <> b.CP_NAME
							OR 
							z.CP_PATRON <> b.CP_PATRON
							OR
							z.CP_POS <> b.CP_POS
							OR
							z.CP_PHONE <> b.CP_PHONE
						)
					ORDER BY ClientLast DESC
				) L
				
			UPDATE a
			SET BUH_FIO = ISNULL(TP_SURNAME + ' ', '') + ISNULL(TP_NAME + ' ', '') + ISNULL(TP_OTCH, ''),
				BUH_SURNAME = REPLACE(TP_SURNAME, 'ё', 'е'),
				BUH_NAME = REPLACE(TP_NAME, 'ё', 'е'),
				BUH_PATRON = REPLACE(TP_OTCH, 'ё', 'е'),
				BUH_POS = POS_NAME,
				BUH_PHONE = TP_PHONE,
				BUH_LAST = TP_LAST
			FROM 
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.TOPersonalTable b ON b.TP_ID_TO = a.TO_ID
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.PositionTable c ON c.POS_ID = b.TP_ID_POS
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ReportPositionTable g ON g.RP_ID = b.TP_ID_RP AND g.RP_PSEDO = 'BUH'

			IF @BUH_PHONE = 1
			BEGIN
				UPDATE #client
				SET BUH_PHONE = dbo.PhoneString(BUH_PHONE)
				
				UPDATE #dbf
				SET BUH_PHONE = dbo.PhoneString(BUH_PHONE)
			END
		END
		
		IF @RES_FIO = 1 OR @RES_POS = 1 OR @RES_PHONE = 1
		BEGIN
			UPDATE a
			SET RES_FIO = CP_FIO,
				RES_SURNAME = REPLACE(CP_SURNAME, 'ё', 'е'),
				RES_NAME = REPLACE(CP_NAME, 'ё', 'е'),
				RES_PATRON = REPLACE(CP_PATRON, 'ё', 'е'),
				RES_POS = CP_POS,
				RES_PHONE = CP_PHONE
				,
				RES_FIO_LAST = L.ClientLast,
				RES_POS_LAST = L.ClientLast,
				RES_PHONE_LAST = L.ClientLast
				/*
				RES_FIO_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalResLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND 
									(
										z.CP_SURNAME <> b.CP_SURNAME
										OR z.CP_NAME <> b.CP_NAME
										OR z.CP_PATRON <> b.CP_PATRON
									)
							ORDER BY ClientLast DESC
						),
				RES_POS_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalResLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_POS <> b.CP_POS
							ORDER BY ClientLast DESC
						),
				RES_PHONE_LAST = 
						(
							SELECT TOP 1 ClientLast
							FROM dbo.ClientPersonalResLastView z
							WHERE a.ClientID = z.ID_MASTER
								AND z.CP_PHONE <> b.CP_PHONE
							ORDER BY ClientLast DESC
						)
				*/
			FROM 
				#client a
				INNER JOIN dbo.ClientPersonalResView b WITH(NOEXPAND) ON a.ClientID = b.CP_ID_CLIENT
				OUTER APPLY
				(
					SELECT TOP 1 ClientLast
					FROM dbo.ClientPersonalResLastView z
					WHERE a.ClientID = z.ID_MASTER
						AND 
						(
							z.CP_SURNAME <> b.CP_SURNAME
							OR 
							z.CP_NAME <> b.CP_NAME
							OR 
							z.CP_PATRON <> b.CP_PATRON
							OR
							z.CP_POS <> b.CP_POS
							OR
							z.CP_PHONE <> b.CP_PHONE
						)
					ORDER BY ClientLast DESC
				) L
				
			UPDATE a
			SET RES_FIO = ISNULL(TP_SURNAME + ' ', '') + ISNULL(TP_NAME + ' ', '') + ISNULL(TP_OTCH, ''),
				RES_SURNAME = REPLACE(TP_SURNAME, 'ё', 'е'),
				RES_NAME = REPLACE(TP_NAME, 'ё', 'е'),
				RES_PATRON = REPLACE(TP_OTCH, 'ё', 'е'),
				RES_POS = POS_NAME,
				RES_PHONE = TP_PHONE,
				RES_LAST = TP_LAST
			FROM 
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.TOPersonalTable b ON b.TP_ID_TO = a.TO_ID
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.PositionTable c ON c.POS_ID = b.TP_ID_POS
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ReportPositionTable g ON g.RP_ID = b.TP_ID_RP AND g.RP_PSEDO = 'RES'

			IF @RES_PHONE = 1
			BEGIN
				UPDATE #client
				SET RES_PHONE = dbo.PhoneString(RES_PHONE)
				
				UPDATE #dbf
				SET RES_PHONE = dbo.PhoneString(RES_PHONE)
			END
		END
		
		IF @SRVC = 1
		BEGIN
			UPDATE a
			SET SERVICE = ServiceName
			FROM 
				#client a
				INNER JOIN dbo.ClientView b ON a.ClientID = b.ClientID
				
			UPDATE a
			SET SERVICE = COUR_NAME
			FROM 
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.TOTable b ON a.TO_ID = b.TO_ID
				INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.CourierTable c ON c.COUR_ID = b.TO_ID_COUR
		END
		
		IF @ADDRESS = 1
		BEGIN
			UPDATE a
			SET CITY_PARENT = b.CT_PARENT,
				CITY = b.CT_NAME,
				PREFIX = b.CT_PREFIX,
				STREET = b.ST_NAME,
				HOME = b.CA_HOME,
				OFFICE = b.CA_OFFICE,
				ADDRESS_LAST = 
						(
							SELECT MAX(ClientLast)
							FROM dbo.ClientAddressLastView z
							WHERE z.ID_MASTER = a.ClientID
								AND z.CA_ID_STREET = b.ST_ID
								AND z.CA_HOME = b.CA_HOME
								AND z.CA_OFFICE = b.CA_OFFICE
						)
			FROM
				#client a
				INNER JOIN dbo.ClientAddressView b ON a.ClientID = b.CA_ID_CLIENT
				
			UPDATE a
			SET CITY = h.CT_NAME,
				STREET = g.ST_NAME,
				HOME = f.TA_HOME,
				ADDRESS_LAST = TO_LAST
			FROM
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TOAddressTable f ON f.TA_ID_TO = a.TO_ID
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.StreetTable g ON g.ST_ID = f.TA_ID_STREET
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.CityTable h ON h.CT_ID = g.ST_ID_CITY
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TOTable n ON n.TO_ID = f.TA_ID_TO
		END	
			
		IF @INN = 1
		BEGIN
			UPDATE a
			SET INN = ClientINN
			FROM 
				#client a
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
				
			UPDATE a
			SET INN = TO_INN
			FROM
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TOTable b ON a.TO_ID = b.TO_ID
		END
		
		IF @NAME = 1
		BEGIN
			UPDATE a
			SET ClientFullName = b.ClientFullName
			FROM 
				#client a
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
				
			UPDATE a
			SET TO_NAME = b.TO_NAME
			FROM
				#dbf a
				INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TOTable b ON a.TO_ID = b.TO_ID
		END
			
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ClientID		INT,
				ClientFullName	VARCHAR(500),
				ManagerName		VARCHAR(100),
				ServiceName		VARCHAR(100),
				TP				VARCHAR(100),
				IN_OIS			VARCHAR(255),
				IN_DBF			VARCHAR(255),
				DISTR			VARCHAR(100),
				DISTR_DBF		VARCHAR(100),
				ERROR			VARCHAR(150),
				CLIENT_LAST		DATETIME,
				DBF_LAST		DATETIME
			)
			
		IF @DIR_FIO = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.DIR_FIO AS IN_OIS, 
					'ФИО руководителя' AS TP,
					e.DIR_FIO AS IN_DBF,
					CASE 
						WHEN 
							a.DIR_SURNAME <> e.DIR_SURNAME
							AND a.DIR_NAME = e.DIR_NAME
							AND a.DIR_PATRON = e.DIR_PATRON
							THEN 'Неверная фамилия (возможно, опечатка)'
						WHEN 
							a.DIR_SURNAME = e.DIR_SURNAME
							AND a.DIR_NAME <> e.DIR_NAME
							AND a.DIR_PATRON = e.DIR_PATRON
							THEN 'Неверное имя (возможно опечатка)'
						WHEN 
							a.DIR_SURNAME = e.DIR_SURNAME
							AND a.DIR_NAME = e.DIR_PATRON
							AND a.DIR_PATRON <> e.DIR_PATRON 
							THEN 'Неверное отчество (возможно опечатка)'
						ELSE 'Совершенно другой сотрудник'
					END AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.DIR_FIO_LAST, e.DIR_LAST
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf d ON d.ClientID = a.ClientID
					INNER JOIN #dbf e ON e.TO_ID = d.TO_ID
				WHERE 
					(
						a.DIR_SURNAME <> e.DIR_SURNAME
						OR a.DIR_NAME <> e.DIR_NAME
						OR a.DIR_PATRON <> e.DIR_PATRON
					)
						
		IF @DIR_POS = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.DIR_POS AS IN_OIS, 
					'Должность руководителя' AS TP,
					d.DIR_POS AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.DIR_POS_LAST, d.DIR_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.DIR_POS <> d.DIR_POS
						)
						
		IF @DIR_PHONE = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.DIR_PHONE AS IN_OIS, 
					'Телефон руководителя' AS TP,
					d.DIR_PHONE AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.DIR_PHONE_LAST, d.DIR_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.DIR_PHONE <> d.DIR_PHONE
						)
						
						
		IF @BUH_FIO = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.BUH_FIO AS IN_OIS, 
					'ФИО гл.бух' AS TP,
					e.BUH_FIO AS IN_DBF,
					CASE 
						WHEN 
							a.BUH_SURNAME <> e.BUH_SURNAME
							AND a.BUH_NAME = e.BUH_NAME
							AND a.BUH_PATRON = e.BUH_PATRON
							THEN 'Неверная фамилия (возможно, опечатка)'
						WHEN 
							a.BUH_SURNAME = e.BUH_SURNAME
							AND a.BUH_NAME <> e.BUH_NAME
							AND a.BUH_PATRON = e.BUH_PATRON
							THEN 'Неверное имя (возможно опечатка)'
						WHEN 
							a.BUH_SURNAME = e.BUH_SURNAME
							AND a.BUH_NAME = e.BUH_PATRON
							AND a.BUH_PATRON <> e.BUH_PATRON 
							THEN 'Неверное отчество (возможно опечатка)'
						ELSE 'Совершенно другой сотрудник'
					END AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.BUH_FIO_LAST, e.BUH_LAST
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf d ON d.ClientID = a.ClientID
					INNER JOIN #dbf e ON e.TO_ID = d.TO_ID
				WHERE 
					(
						a.BUH_SURNAME <> e.BUH_SURNAME
						OR a.BUH_NAME <> e.BUH_NAME
						OR a.BUH_PATRON <> e.BUH_PATRON
					)
						
		IF @BUH_POS = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.BUH_POS AS IN_OIS, 
					'Должность гл.бух' AS TP,
					d.BUH_POS AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.BUH_POS_LAST, d.BUH_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.BUH_POS <> d.BUH_POS
						)
						
		IF @BUH_PHONE = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.BUH_PHONE AS IN_OIS, 
					'Телефон гл.бух' AS TP,
					d.BUH_PHONE AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.BUH_PHONE_LAST, d.BUH_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.BUH_PHONE <> d.BUH_PHONE
						)
						
						
		IF @RES_FIO = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.RES_FIO AS IN_OIS, 
					'ФИО ответственного' AS TP,
					e.RES_FIO AS IN_DBF,
					CASE 
						WHEN 
							a.RES_SURNAME <> e.RES_SURNAME
							AND a.RES_NAME = e.RES_NAME
							AND a.RES_PATRON = e.RES_PATRON
							THEN 'Неверная фамилия (возможно, опечатка)'
						WHEN 
							a.RES_SURNAME = e.RES_SURNAME
							AND a.RES_NAME <> e.RES_NAME
							AND a.RES_PATRON = e.RES_PATRON
							THEN 'Неверное имя (возможно опечатка)'
						WHEN 
							a.RES_SURNAME = e.RES_SURNAME
							AND a.RES_NAME = e.RES_PATRON
							AND a.RES_PATRON <> e.RES_PATRON 
							THEN 'Неверное отчество (возможно опечатка)'
						ELSE 'Совершенно другой сотрудник'
					END AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.RES_FIO_LAST, e.RES_LAST
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf d ON d.ClientID = a.ClientID
					INNER JOIN #dbf e ON e.TO_ID = d.TO_ID
				WHERE 
					(
						a.RES_SURNAME <> e.RES_SURNAME
						OR a.RES_NAME <> e.RES_NAME
						OR a.RES_PATRON <> e.RES_PATRON
					)
						
		IF @RES_POS = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.RES_POS AS IN_OIS, 
					'Должность ответственного' AS TP,
					d.RES_POS AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.RES_POS_LAST, d.RES_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.RES_POS <> d.RES_POS
						)
						
		IF @RES_PHONE = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.RES_PHONE AS IN_OIS, 
					'Телефон ответственного' AS TP,
					d.RES_PHONE AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF,
					a.RES_PHONE_LAST, d.RES_LAST
				FROM
					#client a 
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID				
					INNER JOIN #client_dbf c ON a.ClientID = c.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							a.RES_PHONE <> d.RES_PHONE
						)
						
		IF @SRVC = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.SERVICE AS IN_OIS, 
					'Сервис-инженер' AS TP,
					d.SERVICE AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF, NULL, NULL
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf c ON c.ClientID = a.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							CASE 
								WHEN CHARINDEX(' ', a.SERVICE) <> 0 THEN LEFT(a.SERVICE, CHARINDEX(' ', a.SERVICE) - 1)
								WHEN CHARINDEX('_', a.SERVICE) <> 0 THEN LEFT(a.SERVICE, CHARINDEX('_', a.SERVICE) - 1)
								ELSE a.SERVICE
							END <> 
							CASE 
								WHEN CHARINDEX(' ', d.SERVICE) <> 0 THEN LEFT(d.SERVICE, CHARINDEX(' ', d.SERVICE) - 1)
								ELSE d.SERVICE
							END	
						)
						
		IF @INN = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.INN AS IN_OIS, 
					'ИНН' AS TP,
					d.INN AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF, NULL, NULL
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf c ON c.ClientID = a.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	a.INN <> d.INN
						
		IF @NAME = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					a.ClientFullName AS IN_OIS, 
					'Название' AS TP,
					d.TO_NAME AS IN_DBF,
					'Неправильно и все тут' AS ERROR,	
					DISTR,
					DISTR_DBF, NULL, NULL
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf c ON c.ClientID = a.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	a.ClientFullname <> d.TO_NAME
						
		IF @ADDRESS = 1
			INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, IN_OIS, TP, IN_DBF, ERROR, DISTR, DISTR_DBF, CLIENT_LAST, DBF_LAST)
				SELECT DISTINCT 
					b.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName,
					ISNULL(a.CITY_PARENT + ',' + a.PREFIX + ' ', '') + a.CITY + ',' + a.STREET + ISNULL(',' + NULLIF(a.HOME, ''), '') + CASE ISNULL(',' + NULLIF(a.OFFICE, ''), '') WHEN '' THEN '' ELSE ',' + a.OFFICE END AS IN_OIS, 
					'Адрес' AS TP,
					d.CITY + ',' + d.STREET + CASE ISNULL(d.HOME, '') WHEN '' THEN '' ELSE ',' + d.HOME END AS IN_DBF,
					CASE 
						WHEN a.STREET <> d.STREET
							AND a.CITY = d.CITY
							AND REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									ISNULL(a.HOME, '') + ISNULL(a.OFFICE, ''),
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									)
									=
								REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
										d.HOME, 
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									) THEN 'Неверная улица (возможно, опечатка)'
						WHEN a.STREET = d.STREET													
							AND a.CITY = d.CITY
							AND REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									ISNULL(a.HOME, '') + ISNULL(a.OFFICE, ''),
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									)
									<> 
								REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
										d.HOME,
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									) THEN 'Неверный номер дома/офиса (возможно опечатка)'		
						ELSE 'Совершенно другой адрес'
					END AS ERROR,
					DISTR,
					DISTR_DBF,
					a.ADDRESS_LAST, d.ADDRESS_LAST
				FROM 
					#client a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
					INNER JOIN #client_dbf c ON c.ClientID = a.ClientID
					INNER JOIN #dbf d ON d.TO_ID = c.TO_ID
				WHERE 	(
							REPLACE(ISNULL(a.CITY_PARENT + ',', '') + a.CITY + ','+REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.STREET, 'ул.', ''), 'п.', ''), 'пгт.', ''), ' ', ''), 'с.', ''), 'нп.', '') <> REPLACE(d.CITY + ',' +  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.STREET, 'ул.', ''), 'п.', ''), 'пгт.', ''), ' ', ''), 'с.', ''), 'нп.', '')
							/*a.STREET <> d.STREET
							OR a.CITY <> d.CITY*/
							OR 
								REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									ISNULL(a.HOME, '') + ISNULL(a.OFFICE, ''),
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									)
									<> 
								REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
										d.HOME,
										' ', ''),
										'д.', ''),
										'этаж', ''),
										'эт', ''),
										'к.', ''),
										'каб', ''),
										'кв', ''),
										'оф', ''),
										'.', ''),
										',', ''
									)
						)
		
		SELECT *
		FROM #result
		ORDER BY ManagerName, ServiceName, ClientFullName
		
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
			
		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client
			
		IF OBJECT_ID('tempdb..#dbf') IS NOT NULL
			DROP TABLE #dbf
			
		IF OBJECT_ID('tempdb..#client_dbf') IS NOT NULL
			DROP TABLE #client_dbf	
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END