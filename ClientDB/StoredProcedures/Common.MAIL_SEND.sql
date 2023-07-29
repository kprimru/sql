USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[MAIL_SEND]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[MAIL_SEND]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[MAIL_SEND]
    @Recipients             NVarChar(Max),
    @blind_copy_recipients  NVarChar(Max)   = NULL,
    @Subject                NVarChar(255),
    @Body                   NVarChar(Max),
    @Body_Format            VarChar(20)     = 'TEXT',
	@FromAddress			NVarChar(256)	= NULL
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

        EXEC msdb.dbo.sp_send_dbmail
            --@profile_name           =   'SQLMail',
            @recipients             =   @Recipients,
            @blind_copy_recipients  =   @blind_copy_recipients,
            @body                   =   @Body,
            @body_format            =   @Body_Format,
            @subject                =   @Subject,
            @query_result_header    =   0,
			@from_address			=	@FromAddress;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
