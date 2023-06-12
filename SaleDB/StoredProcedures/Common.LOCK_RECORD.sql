USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[LOCK_RECORD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[LOCK_RECORD]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[LOCK_RECORD]
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

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Common].[LOCK_RECORD] TO public;
GO
