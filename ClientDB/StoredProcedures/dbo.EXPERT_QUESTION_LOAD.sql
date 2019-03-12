USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[EXPERT_QUESTION_LOAD]
	@CPL	NVARCHAR(128),
	@DT		DATETIME,
	@FIO	NVARCHAR(256),
	@PHONE	NVARCHAR(128),
	@EMAIL	NVARCHAR(128),
	@QUEST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SET @DT = DATEADD(HOUR, 7, @DT)

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.ClientDutyQuestion(SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST)
		OUTPUT inserted.ID INTO @TBL
		SELECT SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, REPLACE(QUEST, CHAR(10), '')
		FROM
			(
				SELECT 
					CONVERT(INT, LEFT(@CPL, CHARINDEX('_', @CPL) - 1)) AS SYS,
					CONVERT(INT, 
								CASE 
									WHEN CHARINDEX('_', REVERSE(@CPL)) > 3 THEN 
											RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL))
									ELSE LEFT(RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL)), CHARINDEX('_', RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL))) - 1)
								END) AS DISTR,
					CASE 
						WHEN CHARINDEX('_', REVERSE(@CPL)) > 3 THEN 1
						ELSE CONVERT(INT, REVERSE(LEFT(REVERSE(@CPL), CHARINDEX('_', REVERSE(@CPL)) - 1)))
					END AS COMP, @DT AS DATE, @FIO AS FIO, @EMAIL AS EMAIL, @PHONE AS PHONE, @QUEST AS QUEST
			) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyQuestion b
				WHERE a.SYS = b.SYS AND a.DISTR = b.DISTR AND a.COMP = b.COMP 
					AND a.DATE = b.DATE AND a.FIO = b.FIO AND a.EMAIL = b.EMAIL 
					AND a.PHONE = b.PHONE AND (REPLACE(a.QUEST, CHAR(10), '') = b.QUEST OR a.QUEST = b.QUEST)
			)
			
	DECLARE @ID UNIQUEIDENTIFIER
	
	SELECT @ID = ID FROM @TBL
	
	DECLARE @DUTY INT
	
	SELECT @DUTY = DutyID
	FROM dbo.DutyTable
	WHERE DutyLogin = 'Автомат'
	
	IF @DUTY IS NULL
		SELECT TOP 1 @DUTY = DutyID
		FROM dbo.DutyTable
	
	
	INSERT INTO dbo.ClientDutyTable(ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, DutyID, ClientDutyQuest, EMAIL, 
		ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
		SELECT 
			ID_CLIENT, a.DATE, a.FIO, a.PHONE, @DUTY, a.QUEST, a.EMAIL, 0, '', 0, '',
			(
				SELECT TOP 1 ID
				FROM dbo.CallDirection
				WHERE NAME = 'ВопросЭксперту'
			)
		FROM
			dbo.ClientDutyQuestion a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
		WHERE a.IMPORT IS NULL AND a.ID = @ID
		
	IF @@ROWCOUNT = 0
	BEGIN
		-- если клиента нет - то это подхост
		IF (
				SELECT SubhostName 
				FROM 
					dbo.ClientDutyQuestion a
					INNER JOIN dbo.RegNodeCurrentView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
					INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS	
				WHERE a.IMPORT IS NULL AND a.ID = @ID
			) = 'Л1'
		BEGIN
			-- если это Славянка - то пишем в карточку клиента Славянка
			INSERT INTO dbo.ClientDutyTable(ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, DutyID, ClientDutyQuest, EMAIL, 
						ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
				SELECT 
					3103, a.DATE, a.FIO, a.PHONE, @DUTY, a.QUEST, a.EMAIL, 0, '', 0, '',
					(
						SELECT TOP 1 ID
						FROM dbo.CallDirection
						WHERE NAME = 'ВопросЭксперту'
					)
				FROM dbo.ClientDutyQuestion a
				WHERE a.IMPORT IS NULL AND a.ID = @ID
				
			UPDATE a
			SET IMPORT = GETDATE()
			FROM
				dbo.ClientDutyQuestion a
			WHERE a.IMPORT IS NULL AND a.ID = @ID
		END
	END
		
	UPDATE a
	SET IMPORT = GETDATE()
	FROM
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
		INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
	WHERE a.IMPORT IS NULL AND a.ID = @ID
	
	
	INSERT INTO dbo.ClientDutyTable(ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, 
		DutyID, 
		ClientDutyQuest, EMAIL, 
		ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
		SELECT 
			ID_CLIENT, a.DATE, a.FIO, a.PHONE, 
			@DUTY, 
			a.QUEST, a.EMAIL, 0, '', 0, '',
			(
				SELECT TOP 1 ID
				FROM dbo.CallDirection
				WHERE NAME = 'ВопросЭксперту'
			)
		FROM
			dbo.ClientDutyQuestion a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
		WHERE a.IMPORT IS NULL --AND a.ID = @ID
			AND DATE >= '20170801'
			
	UPDATE a
	SET IMPORT = GETDATE()
	FROM
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
		INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
	WHERE a.IMPORT IS NULL AND DATE >= '20170801'	
END