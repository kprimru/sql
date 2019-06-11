USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[LOCK_RECORD]
	@DATA		VARCHAR(64),
	@REC		NVARCHAR(MAX),
	@REC_STR	NVARCHAR(MAX),	
	@USER		NVARCHAR(128)	OUTPUT,
	@HOST		NVARCHAR(128)	OUTPUT,
	@DATE		DATETIME		OUTPUT,
	@DATE_LEN	VARCHAR(100)	OUTPUT,
	@RESULT		TINYINT			OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		-- 0 - нормальное завершение, 1 - запись заблокирована, 2 - таблица заблокирована
		SET @RESULT = 0
		
		IF EXISTS
			(
				SELECT *
				FROM 
					Common.Locks a
					INNER JOIN sys.dm_exec_sessions b ON 				
						LOCK_SPID		=	session_id AND
						LOCK_HOST		=	host_name AND					
						LOCK_LOGIN		=	original_login_name AND
						a.LOGIN_TIME	=	b.login_time 
				WHERE DATA = @DATA
					AND session_id <> @@SPID
					AND REC IN
						(
							SELECT	ID
							FROM	Common.TableStringFromXML(@REC)
						)
			)
		BEGIN
			SELECT TOP 1 
				@RESULT = 1, @HOST = LOCK_HOST, @DATE = LOCK_TIME, @USER = LOCK_LOGIN,
				@DATE_LEN = Common.TimeSecToStr(DATEDIFF(SECOND, LOCK_TIME, GETDATE()))
			FROM 
				Common.Locks a
				INNER JOIN sys.dm_exec_sessions b ON 				
						LOCK_SPID		=	session_id AND
						LOCK_HOST		=	host_name AND					
						LOCK_LOGIN		=	original_login_name AND
						a.LOGIN_TIME	=	b.login_time  			
			WHERE DATA = @DATA
				AND REC IN
					(
						SELECT	ID
						FROM	Common.TableStringFromXML(@rec)
					)
			ORDER BY LOCK_TIME

			RETURN
		END

		IF EXISTS
			(
				SELECT *
				FROM 
					Common.Locks a
					INNER JOIN sys.dm_exec_sessions b ON 				
							LOCK_SPID		=	session_id AND
							LOCK_HOST		=	host_name AND					
							LOCK_LOGIN		=	original_login_name AND
							a.LOGIN_TIME	=	b.login_time  			
				WHERE DATA = @DATA
					AND session_id <> @@SPID
					AND REC IS NULL
			)
		BEGIN
			SELECT TOP 1 
				@RESULT = 2, @HOST = LOCK_HOST, @DATE = LOCK_TIME, @USER = LOCK_LOGIN,
				@DATE_LEN = Common.TimeSecToStr(DATEDIFF(SECOND, LOCK_TIME, GETDATE()))
			FROM 
				dbo.Locks
				INNER JOIN sys.dm_exec_sessions ON 				
							LOCK_SPID			=	session_id AND
							LOCK_HOST			=	host_name AND					
							LOCK_LOGIN			=	original_login_name AND
							LOCK_LOGIN_TIME		=	login_time  			
			WHERE LOCK_DATA = @DATA
				AND LOCK_REC IS NULL
			ORDER BY LOCK_TIME

			RETURN
		END
			
		EXEC Common.LOCK_RELEASE @REC, @DATA
	
		INSERT INTO Common.Locks(DATA, REC, REC_STR, LOGIN_TIME)
			SELECT @DATA, ID, @REC_STR, login_time
			FROM 
				sys.dm_exec_sessions
				CROSS JOIN Common.TableStringFromXML(@REC)
			WHERE session_id = @@SPID
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
END