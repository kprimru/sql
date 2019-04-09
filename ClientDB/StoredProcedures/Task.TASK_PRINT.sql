USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Task].[TASK_PRINT]
	@USER		NVARCHAR(128),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SHORT		BIT,
	@CLIENT		BIT,
	@PERSONAL	BIT,
	@STATUS		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @USER IS NULL OR (IS_MEMBER('rl_task_all') = 0 AND IS_MEMBER('db_owner') = 0)
		SET @USER = ORIGINAL_LOGIN()	
		
	IF @STATUS IS NULL
		SET @STATUS = 
			(
				SELECT ID AS ITEM
				FROM Task.TaskStatus
				FOR XML PATH(''), ROOT('LIST')
			)
			
	SELECT 
		a.ID, DATE, 
		CONVERT(VARCHAR(20), DATE, 104) + ' (' + DATENAME(WEEKDAY, DATE) + ')' AS DATE_STR, 
		LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS TIME_STR, TIME,
		
		ISNULL('до ' + CONVERT(VARCHAR(20), EXPIRE, 104) + CHAR(10), '') + 
		ISNULL(ClientFullName + CHAR(10), '') +
		CASE 
			WHEN @SHORT = 1 THEN SHORT 
			ELSE SHORT + CHAR(10) + NOTE 
		END + CHAR(10) + '/' + SENDER + '/' AS NOTE, 
			
		INT_VAL, b.NAME AS ST_NAME, ClientFullName
	FROM 
		Task.Tasks a 
		INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
		INNER JOIN dbo.TableGUIDFromXML(@STATUS) d ON d.ID = b.ID
		LEFT OUTER JOIN dbo.ClientTable c ON c.ClientID = ID_CLIENT
	WHERE a.STATUS = 1
		AND DATE BETWEEN @BEGIN AND @END			
		AND 
			(
				-- личные
				@PERSONAL = 1
				AND
					(
						RECEIVER = @USER
						OR
						RECEIVER IN 
							(
								SELECT ServiceLogin 
								FROM 
									dbo.ServiceTable z
									INNER JOIN dbo.ManagerTable y ON z.ManagerID = y.ManagerID 
								WHERE ManagerLogin = @USER
							)
					)
						
				OR 	
									
				@CLIENT = 1 
				AND ID_CLIENT IN 
					(
						SELECT ClientID
						FROM dbo.ClientView WITH(NOEXPAND)
						WHERE ServiceLogin = @USER
							OR ManagerLogin = @USER
					)
		)
		
	UNION ALL
			
			SELECT 
				a.ID, dbo.DateOf(a.DATE), 
				CONVERT(VARCHAR(20), DATE, 104) + ' (' + DATENAME(WEEKDAY, DATE) + ')' AS DATE_STR, 
				LEFT(CONVERT(VARCHAR(20), DATE, 108), 5) AS TIME_STR, DATE,
				
				'Контакт' + CHAR(10) + ISNULL(ClientFullName + CHAR(10), '') + a.NOTE  + CHAR(10) + a.UPD_USER AS NOTE, 
			
				NULL, '', ClientFullName
			FROM 
				dbo.ClientContact a
				INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
			WHERE a.STATUS = 1
				AND a.DATE BETWEEN @BEGIN AND @END			
				AND 
					(
						ID_CLIENT IN 
						(
							SELECT ClientID
							FROM dbo.ClientView WITH(NOEXPAND)
							WHERE ServiceLogin = @USER
								OR ManagerLogin = @USER
						)
						
						OR 
						
						a.UPD_USER = @USER
					)
		
	ORDER BY DATE, TIME, ClientFullName
END
