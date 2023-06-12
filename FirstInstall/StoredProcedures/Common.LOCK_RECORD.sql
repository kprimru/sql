USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[LOCK_RECORD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[LOCK_RECORD]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[LOCK_RECORD]
	@docid		VARCHAR(MAX),
	@dataid		UNIQUEIDENTIFIER,
	@hostname	VARCHAR(128) OUTPUT,
	@loginame	VARCHAR(256) OUTPUT,
	@ntname		VARCHAR(128) OUTPUT,
	@locktime	DATETIME OUTPUT,
	@logintime	DATETIME OUTPUT,
	@result		TINYINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS(
		SELECT *
		FROM
			Common.Locks z INNER JOIN
			sys.dm_exec_sessions b ON
					z.LC_SPID		=	b.session_id AND
					z.LC_HOST		=	b.host_name AND
					z.LC_PROCESS	=	b.host_process_id AND
					z.LC_LOGIN		=	b.original_login_name AND
					z.LC_LOGIN_TIME	=	b.login_time  
		WHERE	z.LC_ID_DATA = @dataid
			AND z.LC_RECORD IN
				(
					SELECT	ID
					FROM	Common.TableFromList(@docid, ',')
				)
		)
	BEGIN
		SELECT
			@hostname	= LC_HOST,
			@loginame	= LC_LOGIN,
			@ntname		= LC_NT_USER,
			@locktime	= LC_LOCK_TIME,
			@logintime	= LC_LOGIN_TIME
		FROM	Common.Locks
		WHERE	LC_RECORD IN
			(
				SELECT	ID
				FROM	Common.TableFromList(@docid, ',')
			)
			AND	LC_ID_DATA	=	@dataid

		SET @result = 1
	END
	ELSE
	BEGIN
		DELETE
		FROM	Common.Locks
		WHERE	LC_RECORD IN
			(
				SELECT	ID
				FROM	Common.TableFromList(@docid, ',')
			)
			AND LC_ID_DATA	=	@dataid

		INSERT INTO Common.Locks(
				LC_ID_DATA, LC_RECORD, LC_LOCK_TIME, LC_SPID, LC_LOGIN,
				LC_HOST, LC_PROCESS, LC_LOGIN_TIME, LC_NT_USER
				)
		        SELECT
					@dataid, ID, GETDATE(), a.session_id, RTRIM(a.original_login_name),
					RTRIM(a.host_name), RTRIM(a.host_process_id), a.login_time, @ntname
				FROM
					sys.dm_exec_sessions a,
					Common.TableFromList(@docid, ',')
				WHERE a.session_id = @@spid

			-- запись свободна для открытия и открывается. данные сохраняются в табл DOC_EDITING_STATUS
		SET @result = 0
	END
END
GO
GRANT EXECUTE ON [Common].[LOCK_RECORD] TO public;
GO
