USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
јвтор:		  ƒенисов јлексей
ќписание:	  
*/

ALTER PROCEDURE [dbo].[OPEN_DOC_STATUS_SP]
	@docid VARCHAR(20),
	@action TINYINT,
	@hostname VARCHAR(128),
    @loginame VARCHAR(256),
    @tablename VARCHAR(128),
    @ntname VARCHAR(128),
    @locktime VARCHAR(128)
WITH EXECUTE AS OWNER

--ѕроцедура отслеживани€ документов, открытых в режиме редактировани€
-- ¬ходные параметры:
--  @docid - идентификатор документа
--  @action - 1-документ открываетс€; 2- документ закрываетс€, 3 - документ удал€етс€
-- ¬ыходные параметры:
--   RETURN -1 ”же открыт, 0 ≈ще не открыт
--  @hostname - рабоча€ станци€
--  @ntname - логин пользовател€
--  @loginame - им€ пользовател€
--  @tablename - название таблицы
--  @locktime - врем€ блокировки

AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
	
		--ѕопытка открыти€ записи. ≈сли она открыта, то возвращаем -1 и станцию с пользователем
		IF @action = 1 
		BEGIN
			IF EXISTS(
				   SELECT a.*
				   FROM dbo.LockTable a INNER JOIN 
						master..sysprocesses b ON a.LC_SP_ID = b.spid AND
												  a.LC_HOST_NAME = b.hostname AND
												  a.LC_HOST_PROCESS = b.hostprocess AND
												  a.LC_LOGIN_NAME = b.loginame AND
												  a.LC_LOGIN_TIME = b.login_time                   
				   WHERE a.LC_DOC_ID = @docid AND 
						 a.LC_TABLE = @tablename
				 ) 
			BEGIN
				SELECT -1 AS LC_RESULT, LC_HOST_NAME, LC_LOGIN_NAME, LC_NT_USER, 
					   CONVERT(varchar, LC_LOCK_TIME, 113) AS LC_LOCK_TIME
				FROM dbo.LockTable a
				WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename
			END
			ELSE 
			BEGIN -- ќткрываем запись и вносим данные о ее открытии в табл. DOC_EDITING_STATUS
				DELETE 
				FROM dbo.LockTable
				WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename

				INSERT INTO dbo.LockTable(LC_DOC_ID, LC_SP_ID, LC_HOST_NAME, LC_HOST_PROCESS, 
								  LC_LOGIN_NAME, LC_LOGIN_TIME, LC_LOCK_TIME, LC_TABLE, LC_NT_USER)
					SELECT 
						@docid, a.spid, RTRIM(a.hostname), RTRIM(a.hostprocess), RTRIM(ORIGINAL_LOGIN()), 
						a.login_time, GETDATE(), @tablename, @ntname
					FROM master..sysprocesses a
					WHERE a.spid = @@spid
					SELECT 0 AS LC_RESULT  
				-- запись свободна дл€ открыти€ и открываетс€. данные сохран€ютс€ в табл DOC_EDITING_STATUS
			END
		END

	-- запись очищаетс€ только тем процессом который ее открыл
		IF @action = 2 
		BEGIN -- «акрытие записи и удаление информации о ней
			DELETE 
			FROM dbo.LockTable
			WHERE 
				LC_DOC_ID = @docid AND
				LC_SP_ID = @@spid AND
				LC_TABLE = @tablename
			SELECT 0 AS LC_RESULT
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[OPEN_DOC_STATUS_SP] TO rl_all_r;
GO