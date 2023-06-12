USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Clients@Select For Lookup]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Clients@Select For Lookup]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Clients@Select For Lookup]
    @Clients_IDs          VarChar(Max)
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

        SELECT C.CL_ID, C.CL_PSEDO
		FROM string_split(@Clients_IDs, ',') AS V
		INNER JOIN dbo.ClientTable AS C ON V.value = C.CL_ID

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Clients@Select For Lookup] TO rl_client_r;
GO
