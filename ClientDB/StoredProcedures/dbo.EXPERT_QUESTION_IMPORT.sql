USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[EXPERT_QUESTION_IMPORT]
	@DATA	NVARCHAR(MAX),
	@DUTY	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @DUTY IS NULL
	BEGIN
		RAISERROR('Вы не являетесь сотрудником дежурной службы! Импорт невозможен', 16, 1)
		RETURN
	END

	DECLARE @XML XML

	SET @XML = CAST(@DATA AS XML)

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.ClientDutyQuestion(SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST)
		OUTPUT inserted.ID INTO @TBL
		SELECT SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST
		FROM
			(
				SELECT
					c.value('(@sys)[1]', 'INT') AS SYS,
					c.value('(@distr)[1]', 'INT') AS DISTR,
					c.value('(@comp)[1]', 'INT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@date)[1]', 'NVARCHAR(64)'), 120) AS DATE,
					c.value('(fio)[1]', 'NVARCHAR(256)') AS FIO,
					c.value('(email)[1]', 'NVARCHAR(256)') AS EMAIL,
					c.value('(phone)[1]', 'NVARCHAR(256)') AS PHONE,
					c.value('(text)[1]', 'NVARCHAR(MAX)') AS QUEST					
				FROM @XML.nodes('root/quest') a(c)
			) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyQuestion z
				WHERE z.SYS = a.SYS
					AND z.DISTR = a.DISTR
					AND z.COMP = a.COMP
					AND z.DATE = a.DATE
					AND z.FIO = a.FIO
					AND z.EMAIL = a.EMAIL
					AND z.PHONE = a.PHONE
					AND z.QUEST = a.QUEST
			)
		
	INSERT INTO dbo.ClientDutyTable(
		ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, DutyID, ClientDutyQuest, EMAIL, 
		ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
		
		SELECT 
			ID_CLIENT, a.DATE, a.FIO, a.PHONE, @DUTY, a.QUEST, a.EMAIL, 0, '', 0, '',
			(
				SELECT TOP 1 ID
				FROM dbo.CallDirection
				WHERE NAME = 'ВопросЭксперту'
			)
		FROM
			@TBL z
			INNER JOIN dbo.ClientDutyQuestion a ON a.ID = z.ID
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
		WHERE a.IMPORT IS NULL
		
	UPDATE dbo.ClientDutyQuestion
	SET IMPORT = GETDATE()
	WHERE ID IN (SELECT ID FROM @TBL)
END
