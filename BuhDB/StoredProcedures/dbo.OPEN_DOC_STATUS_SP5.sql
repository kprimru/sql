USE [BuhDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE dbo.OPEN_DOC_STATUS_SP
	@docid nvarchar(128), 
	@action tinyint,
	@hostname varchar(128) out,
             @loginame varchar(128) out,
             @tablename varchar(128)

--ѕроцедура отслеживани€ документов, открытых в режиме редактировани€
-- ¬ходные параметры:
--  @docid - идентификатор документа
--  @action - 1-документ открываетс€; 2- документ закрываетс€, 3 - документ удал€етс€
-- ¬ыходные параметры:
--   RETURN -1 ”же открыт, 0 ≈ще не открыт
--  @hostname - рабоча€ станци€
--  @loginame - им€ пользовател€
--  @tablename - название таблицы

AS
  SET NOCOUNT ON
 -- ѕопытка открыти€ записи. ≈сли она открыта, то возвращаем -1 и станцию с пользователем
  IF @action = 1 BEGIN
    IF EXISTS(SELECT DOC_EDITING_STATUS.*
              FROM DOC_EDITING_STATUS
                   INNER JOIN master..sysprocesses sysproc ON
                   DOC_EDITING_STATUS.spid = sysproc.spid AND
                   DOC_EDITING_STATUS.hostname = sysproc.hostname AND
                   DOC_EDITING_STATUS.hostprocess = sysproc.hostprocess AND
                   DOC_EDITING_STATUS.loginame = sysproc.loginame AND
                   DOC_EDITING_STATUS.login_time = sysproc.login_time                   
              WHERE DOC_EDITING_STATUS.docid = @docid AND DOC_EDITING_STATUS.tablename = @tablename) BEGIN
	      SELECT 
		@hostname = DOC_EDITING_STATUS.hostname, 
		@loginame = DOC_EDITING_STATUS.loginame
	      FROM DOC_EDITING_STATUS
	      WHERE docid = @docid AND tablename = @tablename
	      RETURN(-1)  -- запись зан€та
	END
    ELSE BEGIN -- ќткрываем запись и вносим данные о ее открытии в табл. DOC_EDITING_STATUS
      DELETE DOC_EDITING_STATUS
      WHERE docid = @docid AND tablename=@tablename
      INSERT INTO DOC_EDITING_STATUS(docid, spid, hostname, hostprocess, loginame, login_time, tablename)
      SELECT @docid,
             sysproc.spid,
             sysproc.hostname,
             sysproc.hostprocess,
             sysproc.loginame,
             sysproc.login_time,
             @tablename
      FROM master..sysprocesses sysproc
      WHERE sysproc.spid = @@spid
      RETURN(0)  -- запись свободна дл€ открыти€ и открываетс€. данные сохран€ютс€ в табл DOC_EDITING_STATUS
    END
  END

-- запись очищаетс€ только тем процессом который ее открыл
  IF @action = 2 BEGIN -- «акрытие записи и удаление информации о ней
    DELETE DOC_EDITING_STATUS
    WHERE docid = @docid AND
          spid = @@spid AND
         tablename = @tablename
    RETURN(0)
  END

--  -- ѕопытка удалени€ записи. ≈сли она открыта, то возвращаем -1 и станцию с пользователем
  IF @action = 3 BEGIN
    IF EXISTS(SELECT DOC_EDITING_STATUS.*
              FROM DOC_EDITING_STATUS
                   INNER JOIN master..sysprocesses sysproc ON
                   DOC_EDITING_STATUS.spid = sysproc.spid AND
                   DOC_EDITING_STATUS.hostname = sysproc.hostname AND
                   DOC_EDITING_STATUS.hostprocess = sysproc.hostprocess AND
                   DOC_EDITING_STATUS.loginame = sysproc.loginame AND
                   DOC_EDITING_STATUS.login_time = sysproc.login_time
              WHERE DOC_EDITING_STATUS.docid = @docid AND DOC_EDITING_STATUS.tablename = @tablename) BEGIN
	      SELECT 
		@hostname = DOC_EDITING_STATUS.hostname,
             		@loginame = DOC_EDITING_STATUS.loginame
       	     FROM DOC_EDITING_STATUS
      	     WHERE docid = @docid AND tablename=@tablename
      	     RETURN(-1) -- запись зан€та
    	END
    ELSE BEGIN
      DELETE DOC_EDITING_STATUS
      WHERE docid = @docid AND
          spid = @@spid AND
          tablename=@tablename
      RETURN(0)
    END
  END
  
  SET NOCOUNT OFF
RETURN(0)