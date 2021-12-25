USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[Http@Get?Data]
    @Url        VarChar(2048),
    @Status     Int             = NULL OUT,
    @Response   NVarChar(Max)   = NULL OUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @responseText Table
    (
        ResponseText NVarChar(max)
    );

    DECLARE @Res Int;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @Res OUT;
        EXEC sp_OAMethod @Res, 'open', NULL, 'GET', @Url, 'false';
        EXEC sp_OAMethod @Res, 'send';
        EXEC sp_OAGetProperty @Res, 'status', @Status OUT;

        INSERT INTO @ResponseText (ResponseText)
        EXEC sp_OAGetProperty @res, 'responseText'

        EXEC sp_OADestroy @res

        -- ToDO а может быть несколько строк?
        SET @Response = (SELECT TOP (1) ResponseText FROM @responseText);

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
