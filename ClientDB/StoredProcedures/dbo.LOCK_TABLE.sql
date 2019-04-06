USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LOCK_TABLE]
	@DATA	VARCHAR(64),
	@NT_NAME	NVARCHAR(128)	OUTPUT,
	@HOST	NVARCHAR(128) OUTPUT,
	@DATE	DATETIME	OUTPUT,
	@DATE_LEN	VARCHAR(100) OUTPUT,
	@RESULT	TINYINT OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	-- 0 - нормальное завершение, 1 - запись заблокирована, 2 - таблица заблокирована
	SET @RESULT = 0

	IF EXISTS
		(
			SELECT *
			FROM 
				dbo.Locks
				INNER JOIN sys.dm_exec_sessions ON 				
						LC_SPID			=	session_id AND
						LC_HOST			=	host_name AND					
						LC_LOGIN		=	original_login_name AND
						LC_LOGIN_TIME	=	login_time  			
			WHERE LC_DATA = @DATA AND LC_REC IS NOT NULL AND session_id <> @@SPID
		)
	BEGIN
		SELECT TOP 1 
			@RESULT = 1, @HOST = LC_HOST, @NT_NAME = LC_NT_USER, @DATE = LC_TIME, 
			@DATE_LEN = dbo.TimeSecToStr(DATEDIFF(SECOND, LC_TIME, GETDATE()))
		FROM 
			dbo.Locks
			INNER JOIN sys.dm_exec_sessions ON 				
						LC_SPID			=	session_id AND
						LC_HOST			=	host_name AND					
						LC_LOGIN		=	original_login_name AND
						LC_LOGIN_TIME	=	login_time  			
		WHERE LC_DATA = @DATA AND LC_REC IS NOT NULL
		ORDER BY LC_TIME

		RETURN
	END

	IF EXISTS
		(
			SELECT *
			FROM 
				dbo.Locks
				INNER JOIN sys.dm_exec_sessions ON 				
						LC_SPID			=	session_id AND
						LC_HOST			=	host_name AND					
						LC_LOGIN		=	original_login_name AND
						LC_LOGIN_TIME	=	login_time  			
			WHERE LC_DATA = @DATA AND LC_REC IS NULL
		)
	BEGIN
		SELECT TOP 1 
			@RESULT = 2, @HOST = LC_HOST, @NT_NAME = LC_NT_USER, @DATE = LC_TIME, 
			@DATE_LEN = dbo.TimeSecToStr(DATEDIFF(SECOND, LC_TIME, GETDATE()))
		FROM 
			dbo.Locks
			INNER JOIN sys.dm_exec_sessions ON 				
						LC_SPID			=	session_id AND
						LC_HOST			=	host_name AND					
						LC_LOGIN		=	original_login_name AND
						LC_LOGIN_TIME	=	login_time  			
		WHERE LC_DATA = @DATA AND LC_REC IS NULL
		ORDER BY LC_TIME

		RETURN
	END
			
	INSERT INTO dbo.Locks(LC_DATA, LC_REC, LC_REC_STR, LC_LOGIN_TIME, LC_NT_USER)
		SELECT @DATA, NULL, NULL, login_time, @NT_NAME
		FROM 
			sys.dm_exec_sessions
		WHERE session_id = @@SPID
END