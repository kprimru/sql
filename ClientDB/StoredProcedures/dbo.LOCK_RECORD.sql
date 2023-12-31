USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[LOCK_RECORD]
	@DATA	VARCHAR(64),
	@REC	NVARCHAR(MAX),
	@REC_STR	NVARCHAR(MAX),
	@NT_NAME	NVARCHAR(128)	OUTPUT,
	@HOST	NVARCHAR(128) OUTPUT,
	@DATE	DATETIME	OUTPUT,
	@DATE_LEN	VARCHAR(100) OUTPUT,
	@RESULT	TINYINT OUTPUT
WITH EXECUTE AS OWNER
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

		-- 0 - нормальное завершение, 1 - запись заблокирована, 2 - таблица заблокирована
		SET @RESULT = 0

		/*
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
				WHERE LC_DATA = @DATA
					AND session_id <> @@SPID
					AND LC_REC IN
						(
							SELECT	ID
							FROM	dbo.TableStringFromXML(@rec)
						)
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
			WHERE LC_DATA = @DATA
				AND LC_REC IN
					(
						SELECT	ID
						FROM	dbo.TableStringFromXML(@rec)
					)
			ORDER BY LC_TIME

			RETURN
		END
		*/

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
				WHERE LC_DATA = @DATA
					AND session_id <> @@SPID
					AND LC_REC IS NULL
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
			WHERE LC_DATA = @DATA
				AND LC_REC IS NULL
			ORDER BY LC_TIME

			RETURN
		END

		EXEC dbo.LOCK_RELEASE @REC, @DATA

		INSERT INTO dbo.Locks(LC_DATA, LC_REC, LC_REC_STR, LC_LOGIN_TIME, LC_NT_USER)
			SELECT @DATA, ID, @REC_STR, login_time, @NT_NAME
			FROM
				sys.dm_exec_sessions
				CROSS JOIN dbo.TableStringFromXML(@REC)
			WHERE session_id = @@SPID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[LOCK_RECORD] TO public;
GO
