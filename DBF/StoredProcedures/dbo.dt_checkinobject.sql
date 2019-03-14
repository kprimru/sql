USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	create proc dbo.dt_checkinobject
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255)='',
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '', /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '',
    @txStream3     Text = ''


as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'


declare @iPropertyObjectId int
select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            exec @iReturn = sp_OAMethod @iObjectId,
                                        'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = @txStream2
        end
        else
        begin
            declare @iStreamObjectId int
            declare @iReturnValue int

            exec @iReturn = sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT
            if @iReturn <> 0 GOTO E_OAError

            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                declare @pos int
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin
                    declare @vchProcLinePiece varchar(255)
                    select @vchProcLinePiece = convert(varchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = sp_OAMethod @iObjectId,
                                        'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = ''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
    return

E_Compile_Fail:
    declare @lerror int
    select @lerror = @@error
    rollback tran compile_all
    RAISERROR (@lerror,16,-1)
    goto CleanUp

E_OAError:
    if @iActionFlag = 1 rollback tran compile_all
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp


