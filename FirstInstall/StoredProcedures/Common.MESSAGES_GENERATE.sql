USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Common].[MESSAGES_GENERATE]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	CREATE TABLE #temp
		(
			MSG_USER VARCHAR(128), 
			MSG_TEXT VARCHAR(MAX), 
			MSG_NOTIFY TINYINT, 
			MSG_DATA VARCHAR(50), 
			MSG_ROW UNIQUEIDENTIFIER,
			MSG_SEND TINYINT DEFAULT 0
		)

	
	DECLARE @RL	UNIQUEIDENTIFIER
	
	SET @RL = Security.RoleID('rl_notify_contract')

	-- есть оплата, но не указан договор	
	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан договор (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND ID_LOCK = 0
			AND ID_FULL_PAY = 1

	SET @RL = Security.RoleID('rl_notify_distr')

	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан дистрибутив (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND IND_CONTRACT IS NOT NULL	
			AND ID_LOCK = 0		
			AND IND_DISTR IS NULL	

	SET @RL = Security.RoleID('rl_notify_claim')
	
	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не сформирована заявка (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND ID_FULL_PAY = 1
			AND IND_CONTRACT IS NOT NULL
			AND ID_RESTORE = 0
			AND ID_LOCK = 0
			AND CLM_ID IS NULL

	SET @RL = Security.RoleID('rl_notify_claim_receive')

	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не отмечено получение заявки (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND CLM_ID IS NOT NULL
			AND ID_LOCK = 0
			AND IND_CLAIM IS NULL

	SET @RL = Security.RoleID('rl_notify_personal')

	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не произведена установка (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND IND_ACT_DATE IS NOT NULL
			AND IND_DISTR IS NOT NULL	
			AND ID_LOCK = 0		
			AND PER_ID IS NULL

	SET @RL = Security.RoleID('rl_notify_act_return')

	INSERT INTO #TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан полный комплект документов (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = @RL
			AND IND_CONTRACT IS NOT NULL
			AND IND_DISTR IS NOT NULL
			AND IND_ACT_DATE IS NOT NULL
			AND PER_ID IS NOT NULL
			AND CLM_ID IS NOT NULL
			AND IND_CLAIM IS NOT NULL
			AND ID_LOCK = 0
			AND IND_ACT_RETURN IS NULL
	
	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #temp (MSG_ROW, MSG_USER)'
	EXEC (@SQL)

	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #temp (MSG_USER) INCLUDE (MSG_SEND, MSG_NOTIFY)'
	EXEC (@SQL)
	
	UPDATE a
	SET MSG_NOTIFY = 0
	FROM Common.Messages a
	WHERE NOT EXISTS		
		(
			SELECT *
			FROM #TEMP b
			WHERE a.MSG_USER = b.MSG_USER
				AND a.MSG_TEXT = b.MSG_TEXT
				AND a.MSG_ROW = b.MSG_ROW
		)
				
	UPDATE t 
	SET MSG_SEND = 1,
		MSG_NOTIFY = 2
	FROM 
		#TEMP t INNER JOIN
		Security.UserActive ON US_ID_MASTER = MSG_USER INNER JOIN
		sys.dm_exec_sessions z ON US_LOGIN = original_login_name
	WHERE z.program_name = 'FirstInstall' AND MSG_SEND = 0 AND MSG_NOTIFY = 1

	INSERT INTO Common.Messages(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW, MSG_SEND)
		SELECT MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW, MSG_SEND
		FROM #TEMP a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Common.Messages b
				WHERE a.MSG_USER = b.MSG_USER
					AND a.MSG_TEXT = b.MSG_TEXT
					AND a.MSG_ROW = b.MSG_ROW
			)
	
	--IF DB_ID('ARM') IS NULL
	--	RETURN

	INSERT INTO ARM.dbo.ARM_MESSAGES(U_DATA, U_LOGIN, U_MESSAGE, ARM_ID)
		SELECT GETDATE(), US_LOGIN, MSG_TEXT, 3
		FROM 
			Common.Messages INNER JOIN
			Security.UserActive ON US_ID_MASTER = MSG_USER
		WHERE NOT EXISTS
			(
				SELECT *
				FROM ARM.dbo.ARM_MESSAGES
				WHERE ARM_ID = 3 AND U_MESSAGE = MSG_TEXT AND US_LOGIN = U_LOGIN
			) AND MSG_SEND = 0

	UPDATE Common.Messages
	SET MSG_SEND = 1
	WHERE MSG_SEND = 0	

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	/*
	DECLARE @TEMP TABLE(
			MSG_USER VARCHAR(128), 
			MSG_TEXT VARCHAR(MAX), 
			MSG_NOTIFY TINYINT, 
			MSG_DATA VARCHAR(50), 
			MSG_ROW UNIQUEIDENTIFIER,
			MSG_SEND TINYINT DEFAULT 0)

	
	-- есть оплата, но не указан договор	
	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан договор (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_contract')
			AND ID_LOCK = 0
			AND ID_FULL_PAY = 1

	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан дистрибутив (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_distr')
			AND IND_CONTRACT IS NOT NULL	
			AND ID_LOCK = 0		
			AND IND_DISTR IS NULL	

	
	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не сформирована заявка (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_claim')
			AND ID_FULL_PAY = 1
			AND IND_CONTRACT IS NOT NULL
			AND ID_LOCK = 0
			AND CLM_ID IS NULL

	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не отмечено получение заявки (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_claim_receive')			
			AND CLM_ID IS NOT NULL
			AND ID_LOCK = 0
			AND IND_CLAIM IS NULL

	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не произведена установка (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_personal')
			AND IND_ACT_DATE IS NOT NULL
			AND IND_DISTR IS NOT NULL	
			AND ID_LOCK = 0		
			AND PER_ID IS NULL

	INSERT INTO @TEMP(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW)
		SELECT RM_ID_USER, 'Не указан полный комплект документов (' + CL_NAME + '  ' + SYS_SHORT + ')', 1, 'INSTALL', IND_ID
		FROM 
			Security.RoleMessages CROSS JOIN
			Install.InstallFullView
		WHERE RM_ID_ROLE = Security.RoleID('rl_notify_act_return')
			AND IND_CONTRACT IS NOT NULL
			AND IND_DISTR IS NOT NULL
			AND IND_ACT_DATE IS NOT NULL
			AND PER_ID IS NOT NULL
			AND CLM_ID IS NOT NULL
			AND IND_CLAIM IS NOT NULL
			AND ID_LOCK = 0
			AND IND_ACT_RETURN IS NULL
	
	UPDATE a
	SET MSG_NOTIFY = 0
	FROM Common.Messages a
	WHERE NOT EXISTS		
		(
			SELECT *
			FROM @TEMP b
			WHERE a.MSG_USER = b.MSG_USER
				AND a.MSG_TEXT = b.MSG_TEXT
				AND a.MSG_ROW = b.MSG_ROW
		)
				
	UPDATE t 
	SET MSG_SEND = 1,
		MSG_NOTIFY = 2
	FROM 
		@TEMP t INNER JOIN
		Security.UserActive ON US_ID_MASTER = MSG_USER INNER JOIN
		sys.dm_exec_sessions z ON US_LOGIN = original_login_name
	WHERE z.program_name = 'FirstInstall' AND MSG_SEND = 0 AND MSG_NOTIFY = 1

	INSERT INTO Common.Messages(MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW, MSG_SEND)
		SELECT MSG_USER, MSG_TEXT, MSG_NOTIFY, MSG_DATA, MSG_ROW, MSG_SEND
		FROM @TEMP a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Common.Messages b
				WHERE a.MSG_USER = b.MSG_USER
					AND a.MSG_TEXT = b.MSG_TEXT
					AND a.MSG_ROW = b.MSG_ROW
			)
	
	IF DB_ID('ARM') IS NULL
		RETURN

	INSERT INTO ARM.dbo.ARM_MESSAGES(U_DATA, U_LOGIN, U_MESSAGE, ARM_ID)
		SELECT GETDATE(), US_LOGIN, MSG_TEXT, 3
		FROM 
			Common.Messages INNER JOIN
			Security.UserActive ON US_ID_MASTER = MSG_USER
		WHERE NOT EXISTS
			(
				SELECT *
				FROM ARM.dbo.ARM_MESSAGES
				WHERE ARM_ID = 3 AND U_MESSAGE = MSG_TEXT AND US_LOGIN = U_LOGIN
			) AND MSG_SEND = 0

	UPDATE Common.Messages
	SET MSG_SEND = 1
	WHERE MSG_SEND = 0	
	*/
END
