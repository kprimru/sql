USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[MAIL_SEND]
    @Recipients             VarChar(Max),
    @blind_copy_recipients  VarChar(Max)    = NULL,
    @Subject                VarChar(255),
    @Body                   NVarChar(Max),
    @Body_Format            VarChar(20)     = 'TEXT'
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    EXEC msdb.dbo.sp_send_dbmail
        --@profile_name           =   'SQLMail',
        @recipients             =   @Recipients,
        @blind_copy_recipients  =   @blind_copy_recipients,
        @body                   =   @Body,
        @body_format            =   @Body_Format,
        @subject                =   @Subject,
        @query_result_header    =   0;
END
GO
