USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_SELECT]
	@SEARCH		NVARCHAR(MAX)	=	NULL,
	@NAME		NVARCHAR(512)	=	NULL,
	@NUMBER		NVARCHAR(MAX)	=	NULL,
	@PHONE		NVARCHAR(128)	=	NULL,
	@PERSONAL	NVARCHAR(256)	=	NULL,
	@ACTIVITY	NVARCHAR(MAX)	=	NULL,
	@PAY_CAT	NVARCHAR(MAX)	=	NULL,
	@AREA		NVARCHAR(MAX)	=	NULL,
	@STREET		NVARCHAR(MAX)	=	NULL,
	@HOME		NVARCHAR(128)	=	NULL,
	@ROOM		NVARCHAR(128)	=	NULL,
	@AVAILAB	NVARCHAR(MAX)	=	NULL,
	@SENDER		NVARCHAR(MAX)	=	NULL,
	@WSTATE		NVARCHAR(MAX)	=	NULL,
	@WSTATUS	NVARCHAR(MAX)	=	NULL,
	@DBEGIN		SMALLDATETIME	=	NULL,
	@DEND		SMALLDATETIME	=	NULL,
	@POTENT		NVARCHAR(MAX)	=	NULL,
	@MONTH		NVARCHAR(MAX)	=	NULL,
	@TAXING		NVARCHAR(MAX)	=	NULL,
	@SALE		NVARCHAR(MAX)	=	NULL,
	@AGENT		NVARCHAR(MAX)	=	NULL,
	@RIVAL		NVARCHAR(MAX)	=	NULL,
	@CHARACTER	NVARCHAR(MAX)	=	NULL,
	@REMOTE		NVARCHAR(MAX)	=	NULL,
	@SELECT		BIT				=	NULL,
	@RC			INT				=	NULL OUTPUT,
	@MANAGER	NVARCHAR(MAX)	=	NULL,
	@CARD		TINYINT			=	NULL,
	@DELETED	BIT				=	NULL,
	@HISTORY	BIT				=	NULL,
	@RIVAL_PERS	NVARCHAR(MAX)	=	NULL,
	@CALL_BEGIN	SMALLDATETIME	=	NULL,
	@CALL_END	SMALLDATETIME	=	NULL,
	@BLACK		BIT				=	NULL,
	@BLACK_NOTE	NVARCHAR(128)	=	NULL,
	@PROJECT	NVARCHAR(MAX)	=	NULL,
	@EMAIL		NVARCHAR(256)	=	NULL,
	@DEPO		BIT				=	NULL,
	@DEPO_NUM	NVARCHAR(MAX)	=	NULL,
	@RIVALV		NVARCHAR(MAX)	=	NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @CARD = 0
		SET @CARD = NULL

	IF @HISTORY IS NULL
		SET @HISTORY = 0

	IF @HOME IS NOT NULL
	BEGIN
		SET @HOME = REPLACE(@HOME, '%', ' ')
		SET @HOME = LTRIM(RTRIM(@HOME))
	END

	IF OBJECT_ID('tempdb..#company') IS NOT NULL
		DROP TABLE #company	

	CREATE TABLE #company
		(
			ID	UNIQUEIDENTIFIER PRIMARY KEY
		)

	IF OBJECT_ID('tempdb..#rlist') IS NOT NULL
		DROP TABLE #rlist

	CREATE TABLE #rlist 
		(
			ID	UNIQUEIDENTIFIER PRIMARY KEY
		)

	IF OBJECT_ID('tempdb..#wlist') IS NOT NULL
		DROP TABLE #wlist

	CREATE TABLE #wlist 
		(
			ID	UNIQUEIDENTIFIER PRIMARY KEY
		)

	BEGIN TRY
		INSERT INTO #rlist(ID)
			SELECT ID 
			FROM Client.CompanyReadList()

		INSERT INTO #wlist(ID)
			SELECT ID 
			FROM Client.CompanyWriteList()

		IF @DELETED = 1
			INSERT INTO #rlist(ID)
				SELECT ID
				FROM Client.Company
				WHERE STATUS = 3

		IF @SEARCH IS NOT NULL
		BEGIN
			INSERT INTO #company(ID)
				SELECT ID 
				FROM #rlist

			IF OBJECT_ID('tempdb..#search') IS NOT NULL
				DROP TABLE #search	

			CREATE TABLE #search
				(
					WRD		VARCHAR(250) PRIMARY KEY
				)		

			INSERT INTO #search(WRD)
				SELECT DISTINCT '%' + Word + '%'
				FROM Common.SplitString(@SEARCH)		

			DELETE 
			FROM #company
			WHERE ID IN
				(
					/*
					SELECT ID
					FROM Client.CompanySearchView
					*/
					SELECT ID_COMPANY
					FROM Client.CompanyIndex
					WHERE EXISTS
						(
							SELECT * FROM #search WHERE NOT (DATA LIKE WRD)
						)
				)
				
			IF @SELECT = 1
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID_COMPANY
						FROM Client.CompanySelection
						WHERE USR_NAME = ORIGINAL_LOGIN()
					)

			IF OBJECT_ID('tempdb..#search') IS NOT NULL
				DROP TABLE #search
		END
		ELSE
		BEGIN
			IF @NUMBER IS NOT NULL
				INSERT INTO #company(ID)
					SELECT ID
					FROM Client.Company
					WHERE NUMBER IN
						( 
							SELECT ITEM
							FROM Common.IntTableFromList(@NUMBER , ',')
						)
						AND (STATUS = 1 OR STATUS = 3 AND @DELETED = 1)
			ELSE IF @PHONE IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT ID_COMPANY
					FROM 
						Client.CompanyPhone a
						INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
					WHERE PHONE_S LIKE @PHONE
						AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1) AND a.STATUS = 1

					UNION

					SELECT DISTINCT c.ID
					FROM 
						Client.CompanyPersonal a
						INNER JOIN Client.CompanyPersonalPhone b ON a.ID = b.ID_PERSONAL
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE b.PHONE_S LIKE @PHONE
						AND a.STATUS = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @PERSONAL IS NOT NULL 
				INSERT INTO #company(ID)
					SELECT DISTINCT b.ID
					FROM 
						Client.CompanyPersonal a
						INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
					WHERE FIO LIKE @PERSONAL
						AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1)
			ELSE IF @EMAIL IS NOT NULL 
				INSERT INTO #company(ID)
					SELECT DISTINCT b.ID
					FROM 
						Client.CompanyPersonal a
						INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
					WHERE (a.EMAIL LIKE @EMAIL OR b.EMAIL LIKE @EMAIL)
						AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1)
			ELSE IF @NAME IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						LEFT OUTER JOIN Client.Office b ON a.ID = b.ID_COMPANY
					WHERE (a.NAME LIKE @NAME OR b.NAME LIKE @NAME) 
						AND (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND ISNULL(b.STATUS, 1) = 1
			ELSE IF @ACTIVITY IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Client.CompanyActivity t ON t.ID_COMPANY = a.ID
						INNER JOIN Common.TableGUIDFromXML(@ACTIVITY) b ON t.ID_ACTIVITY = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @PAY_CAT IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@PAY_CAT) b ON a.ID_PAY_CAT = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @AREA IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
						INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
						INNER JOIN Common.TableGUIDFromXML(@AREA) d ON c.ID_AREA = d.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1				
			ELSE IF @STREET IS NOT NULL OR @HOME IS NOT NULL OR @ROOM IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
						INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1
						AND (HOME = @HOME OR @HOME IS NULL)
						AND (ROOM LIKE @ROOM OR @ROOM IS NULL)
						AND (c.ID_STREET IN (SELECT ID FROM Common.TableGUIDFromXML(@STREET)) OR @STREET IS NULL)
			ELSE IF @AVAILAB IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@AVAILAB) b ON a.ID_AVAILABILITY = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @SENDER IS NOT NULL
				INSERT INTO #company
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@SENDER) b ON a.ID_SENDER = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @TAXING IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Client.CompanyTaxing t ON t.ID_COMPANY = a.ID
						INNER JOIN Common.TableGUIDFromXML(@TAXING) b ON t.ID_TAXING = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @WSTATE IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@WSTATE) b ON a.ID_WORK_STATE = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @WSTATUS IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@WSTATUS) b ON a.ID_WORK_STATUS = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @DBEGIN IS NOT NULL OR @DEND IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM Client.Company a
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
						AND (WORK_DATE >= @DBEGIN OR @DBEGIN IS NULL)
						AND (WORK_DATE <= @DEND OR @DEND IS NULL)			
			ELSE IF @POTENT IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@POTENT) b ON a.ID_POTENTIAL = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @MONTH IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@MONTH) b ON a.ID_NEXT_MON = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @SALE IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 						
						Client.CompanyProcess a
						INNER JOIN Common.TableGUIDFromXML(@SALE) b ON a.ID_PERSONAL = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.PROCESS_TYPE = N'SALE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @RIVAL_PERS IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 						
						Client.CompanyProcess a
						INNER JOIN Common.TableGUIDFromXML(@RIVAL_PERS) b ON a.ID_PERSONAL = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.PROCESS_TYPE = N'RIVAL' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @MANAGER IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 						
						Client.CompanyProcess a
						INNER JOIN Common.TableGUIDFromXML(@MANAGER) b ON a.ID_PERSONAL = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.PROCESS_TYPE = N'MANAGER' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @AGENT IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 						
						Client.CompanyProcess a
						INNER JOIN Common.TableGUIDFromXML(@AGENT) b ON a.ID_PERSONAL = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.PROCESS_TYPE = N'PHONE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @RIVAL IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 
						Client.CompanyRival a
						INNER JOIN Common.TableGUIDFromXML(@RIVAL) b ON a.ID_RIVAL = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.STATUS = 1 AND ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @RIVALV IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID_COMPANY
					FROM 
						Client.CompanyRival a
						INNER JOIN Common.TableGUIDFromXML(@RIVALV) b ON a.ID_VENDOR = b.ID
						INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
					WHERE a.STATUS = 1 AND ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
			ELSE IF @CHARACTER IS NOT NULL
				INSERT INTO #company(ID)
					SELECT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@CHARACTER) b ON a.ID_CHARACTER = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @REMOTE IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Common.TableGUIDFromXML(@REMOTE) b ON a.ID_REMOTE = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @PROJECT IS NOT NULL
				INSERT INTO #company(ID)
					SELECT DISTINCT a.ID
					FROM 
						Client.Company a
						INNER JOIN Client.CompanyProject c ON a.ID = c.ID_COMPANY
						INNER JOIN Common.TableGUIDFromXML(@PROJECT) b ON c.ID_PROJECT = b.ID
					WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
			ELSE IF @CALL_BEGIN	IS NOT NULL OR @CALL_END IS NOT NULL
				INSERT INTO #company(ID)
					SELECT ID_COMPANY
					FROM Client.CallDate
					WHERE (DATE >= @CALL_BEGIN OR @CALL_BEGIN IS NULL)
						AND (DATE <= @CALL_END OR @CALL_END IS NULL)
			ELSE IF @BLACK = 1
				INSERT INTO #company(ID)
					SELECT ID
					FROM Client.Company
					WHERE STATUS = 1 AND BLACK_LIST = 1				
			ELSE IF @BLACK_NOTE IS NOT NULL
				INSERT INTO #company(ID)
					SELECT ID
					FROM Client.Company
					WHERE STATUS = 1 AND BLACK_NOTE LIKE @BLACK_NOTE
			ELSE IF @DEPO = 1
				INSERT INTO #company(ID)
					SELECT ID
					FROM Client.Company
					WHERE STATUS = 1 AND DEPO = 1
			ELSE IF @DEPO_NUM IS NOT NULL
				INSERT INTO #company(ID)
					SELECT ID
					FROM Client.Company
					WHERE STATUS = 1 AND DEPO_NUM IN
						(
							SELECT ITEM
							FROM Common.IntTableFromList(@DEPO_NUM, ',')
						)
			ELSE
				INSERT INTO #company(ID)
					SELECT ID 
					FROM #rlist
			
			DELETE 
			FROM #company
			WHERE ID NOT IN
				(
					SELECT ID 
					FROM #rlist
				)			

			IF @NAME IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							LEFT OUTER JOIN Client.Office b ON a.ID = b.ID_COMPANY
						WHERE (a.NAME LIKE @NAME OR b.NAME LIKE @NAME) 
							AND (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND ISNULL(b.STATUS, 1) = 1
					)

			IF @NUMBER IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID
						FROM Client.Company
						WHERE NUMBER IN 
							( 
								SELECT ITEM
								FROM Common.IntTableFromList(@NUMBER , ',')
							)
							AND (STATUS = 1 OR STATUS = 3 AND @DELETED = 1)
					)

			IF @PHONE IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID_COMPANY
						FROM 
							Client.CompanyPhone a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE PHONE_S LIKE @PHONE
							AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1) AND a.STATUS = 1

						UNION ALL

						SELECT c.ID
						FROM 
							Client.CompanyPersonal a
							INNER JOIN Client.CompanyPersonalPhone b ON a.ID = b.ID_PERSONAL
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE b.PHONE_S LIKE @PHONE
							AND a.STATUS = 1 AND (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @PERSONAL IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(					
						SELECT b.ID
						FROM 
							Client.CompanyPersonal a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE FIO LIKE @PERSONAL
							AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @EMAIL IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(					
						SELECT b.ID
						FROM 
							Client.CompanyPersonal a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE (a.EMAIL LIKE @EMAIL OR b.EMAIL LIKE @EMAIL)
							AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1)
					)
		
			IF @ACTIVITY IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Client.CompanyActivity t ON a.ID = t.ID_COMPANY
							INNER JOIN Common.TableGUIDFromXML(@ACTIVITY) b ON t.ID_ACTIVITY = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @PAY_CAT IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@PAY_CAT) b ON a.ID_PAY_CAT = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @AREA IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
							INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
							INNER JOIN Common.TableGUIDFromXML(@AREA) d ON c.ID_AREA = d.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1
					)

			IF @STREET IS NOT NULL OR @HOME IS NOT NULL OR @ROOM IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
							INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1
							AND (HOME = @HOME OR @HOME IS NULL)
							AND (ROOM LIKE @ROOM OR @ROOM IS NULL)
							AND (c.ID_STREET IN (SELECT ID FROM Common.TableGUIDFromXML(@STREET)) OR @STREET IS NULL)
					)					
						
			IF @AVAILAB IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@AVAILAB) b ON a.ID_AVAILABILITY = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @SENDER IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@SENDER) b ON a.ID_SENDER = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)
		
			IF @TAXING IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Client.CompanyTaxing t ON a.ID = t.ID_COMPANY
							INNER JOIN Common.TableGUIDFromXML(@TAXING) b ON t.ID_TAXING = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @WSTATE IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@WSTATE) b ON a.ID_WORK_STATE = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @WSTATUS IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@WSTATUS) b ON a.ID_WORK_STATUS = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @DBEGIN IS NOT NULL OR @DEND IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM Client.Company a
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
							AND (WORK_DATE >= @DBEGIN OR @DBEGIN IS NULL)
							AND (WORK_DATE <= @DEND OR @DEND IS NULL)
					)

			IF @POTENT IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@POTENT) b ON a.ID_POTENTIAL = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @MONTH IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@MONTH) b ON a.ID_NEXT_MON = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @SALE IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 						
							Client.CompanyProcess a
							INNER JOIN Common.TableGUIDFromXML(@SALE) b ON a.ID_PERSONAL = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.PROCESS_TYPE = N'SALE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @RIVAL_PERS IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 						
							Client.CompanyProcess a
							INNER JOIN Common.TableGUIDFromXML(@RIVAL_PERS) b ON a.ID_PERSONAL = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.PROCESS_TYPE = N'RIVAL' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @MANAGER IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 						
							Client.CompanyProcess a
							INNER JOIN Common.TableGUIDFromXML(@MANAGER) b ON a.ID_PERSONAL = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.PROCESS_TYPE = N'MANAGER' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)

			IF @AGENT IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 						
							Client.CompanyProcess a
							INNER JOIN Common.TableGUIDFromXML(@AGENT) b ON a.ID_PERSONAL = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.PROCESS_TYPE = N'PHONE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)

			IF @RIVAL IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 
							Client.CompanyRival a
							INNER JOIN Common.TableGUIDFromXML(@RIVAL) b ON a.ID_RIVAL = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.STATUS = 1 AND  ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @RIVALV IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID_COMPANY
						FROM 
							Client.CompanyRival a
							INNER JOIN Common.TableGUIDFromXML(@RIVALV) b ON a.ID_VENDOR = b.ID
							INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
						WHERE a.STATUS = 1 AND  ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
					)

			IF @CHARACTER IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@CHARACTER) b ON a.ID_CHARACTER = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)

			IF @REMOTE IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Common.TableGUIDFromXML(@REMOTE) b ON a.ID_REMOTE = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @PROJECT IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM 
							Client.Company a
							INNER JOIN Client.CompanyProject t ON a.ID = t.ID_COMPANY
							INNER JOIN Common.TableGUIDFromXML(@PROJECT) b ON t.ID_PROJECT = b.ID
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
					)
					
			IF @CARD IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT a.ID
						FROM Client.Company a
						WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
							AND a.CARD = @CARD
					)
					
			IF @CALL_BEGIN	IS NOT NULL OR @CALL_END IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID_COMPANY
						FROM Client.CallDate
						WHERE (DATE >= @CALL_BEGIN OR @CALL_BEGIN IS NULL)
							AND (DATE <= @CALL_END OR @CALL_END IS NULL)
					)
					
			IF @BLACK = 1
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID
						FROM Client.Company
						WHERE STATUS = 1
							AND BLACK_LIST = 1
					)
					
			IF @BLACK_NOTE IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID
						FROM Client.Company
						WHERE STATUS = 1
							AND BLACK_NOTE LIKE @BLACK_NOTE
					)
					
			IF @DEPO = 1
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID
						FROM Client.Company
						WHERE STATUS = 1
							AND DEPO = 1
					)
					
			IF @DEPO_NUM IS NOT NULL
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID
						FROM Client.Company
						WHERE STATUS = 1
							AND DEPO_NUM IN
								(
									SELECT ITEM
									FROM Common.IntTableFromList(@DEPO_NUM, ',')
								)
					)
					
			IF @SELECT = 1
				DELETE FROM #company
				WHERE ID NOT IN
					(
						SELECT ID_COMPANY
						FROM Client.CompanySelection
						WHERE USR_NAME = ORIGINAL_LOGIN()
					)	
		END
		
		/*
		IF OBJECT_ID('tempdb..#address') IS NOT NULL
			DROP TABLE #address
			
		CREATE TABLE #address
			(
				CO_ID	UNIQUEIDENTIFIER PRIMARY KEY,
				AD_STR	NVARCHAR(1024)
			)
			
		INSERT INTO #address(CO_ID, AD_STR)
			SELECT ID, AD_STR
			FROM 
				#company a
				CROSS APPLY
					(
						SELECT TOP 1 AD_STR
						FROM Client.OfficeAddressMainView WITH(NOEXPAND)
						WHERE CO_ID = a.ID
						ORDER BY MAIN DESC, ID 
					) b
		*/
		
		
		SELECT
			a.ID, NUMBER, b.STATUS,
			/*
			(
				SELECT TOP 1 AD_STR
				FROM Client.OfficeAddressMainView WITH(NOEXPAND)
				WHERE CO_ID = a.ID
				ORDER BY MAIN DESC, ID
			) AS SHORT*/
			t.ADDRESS AS SHORT, b.NAME, CONVERT(BIT, CASE WHEN c.ID IS NOT NULL THEN 1 ELSE 0 END) AS WRITE,			
			d.NAME AS AVA_NAME, e.NAME AS POT_NAME, f.NAME AS WS_NAME, g.NAME AS PC_NAME, 
			h.SHORT AS PHONE_SHORT, j.SHORT AS SALE_SHORT, n.SHORT AS MAN_SHORT, s.SHORT AS RIVAL_SHORT,
			l.NAME AS MON_NAME, l.DATE AS MON_DATE, WORK_DATE, BLACK_LIST, q.NAME AS CHAR_NAME, PAPER_CARD, b.DEPO,
			REVERSE(STUFF(REVERSE(
				(
					SELECT y.NAME + ', '
					FROM 
						Client.CompanyProject z
						INNER JOIN Client.Project y ON z.ID_PROJECT = y.ID
					WHERE ID_COMPANY = a.ID
					/*ORDER BY y.NAME */FOR XML PATH('')			
			)), 1, 2, '')) AS PRJ_NAME,
			CONVERT(BIT, 
					CASE 
						WHEN m.ID IS NULL THEN 0
						ELSE 1
					END
				) AS CONTROL,
			CONVERT(BIT, 
					CASE 
						WHEN p.ID IS NULL THEN 0
						ELSE 1
					END
				) AS ARCHIVE,
			CONVERT(BIT, CASE
				WHEN r.ID IS NULL THEN 0
				ELSE 1
			END) AS HISTORY,
			u.DATE AS CALL_DATE,
			w.INDX,
			CONVERT(BIT, CASE
				WHEN d.COLOR IS NULL THEN 0
				ELSE 1 
			END) AS AVA,
			d.COLOR AS AVA_COLOR,
			CONVERT(BIT, 
					CASE 
						WHEN war.ID_COMPANY IS NULL THEN 0
						ELSE 1
					END
				) AS WARNING,
			b.DEPO_NUM
		FROM 
			#company a
			INNER JOIN Client.Company b ON a.ID = b.ID
			LEFT OUTER JOIN Client.CompanyIndex t ON t.ID_COMPANY = a.ID
			LEFT OUTER JOIN #wlist c ON c.ID = a.ID
			LEFT OUTER JOIN Client.Availability d ON d.ID = b.ID_AVAILABILITY
			LEFT OUTER JOIN Client.Potential e ON e.ID = b.ID_POTENTIAL
			LEFT OUTER JOIN Client.WorkState f ON f.ID = b.ID_WORK_STATE
			LEFT OUTER JOIN Client.PayCategory g ON g.ID = b.ID_PAY_CAT
			LEFT OUTER JOIN Client.CompanyProcessPhoneView h WITH(NOEXPAND) ON h.ID = b.ID
			LEFT OUTER JOIN Client.CompanyProcessSaleView j WITH(NOEXPAND) ON j.ID = b.ID
			LEFT OUTER JOIN Common.Month l ON l.ID = b.ID_NEXT_MON
			LEFT OUTER JOIN (SELECT DISTINCT ID, ID_COMPANY FROM Client.CompanyControlView WITH(NOEXPAND)) AS m ON m.ID_COMPANY = a.ID
			LEFT OUTER JOIN Client.CompanyProcessManagerView n WITH(NOEXPAND) ON n.ID = b.ID
			LEFT OUTER JOIN (SELECT DISTINCT ID, ID_COMPANY FROM Client.CompanyArchiveView WITH(NOEXPAND)) AS p ON p.ID_COMPANY = a.ID
			LEFT OUTER JOIN Client.Character q ON q.ID = b.ID_CHARACTER
			LEFT OUTER JOIN Client.CompanyCallView r WITH(NOEXPAND) ON r.ID = a.ID
			LEFT OUTER JOIN Client.CompanyProcessRivalView s WITH(NOEXPAND) ON s.ID = b.ID
			LEFT OUTER JOIN Client.CallDate u ON u.ID_COMPANY = a.ID
			LEFT OUTER JOIN Client.Sender w ON w.ID = b.ID_SENDER
			--LEFT OUTER JOIN Client.Project prj ON prj.ID = b.ID_PROJECT
			LEFT OUTER JOIN (SELECT DISTINCT ID_COMPANY FROM Client.CompanyWarningView WITH(NOEXPAND)) AS war ON war.ID_COMPANY = a.ID
		WHERE @HISTORY = 0 OR r.ID IS NOT NULL
		ORDER BY b.NAME, NUMBER
		--OPTION (FAST 25)


		SELECT @RC = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT 
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH

	IF OBJECT_ID('tempdb..#company') IS NOT NULL
		DROP TABLE #company

	IF OBJECT_ID('tempdb..#rlist') IS NOT NULL
		DROP TABLE #rlist

	IF OBJECT_ID('tempdb..#wlist') IS NOT NULL
		DROP TABLE #wlist
		
	/*
	IF OBJECT_ID('tempdb..#address') IS NOT NULL
		DROP TABLE #address
	*/
END