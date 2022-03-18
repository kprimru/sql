USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Queue].[Online Passwords@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Queue].[Online Passwords@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Queue].[Online Passwords@Select]
    @Id             UniqueIdentifier,
    @Host_id        SmallInt,
    @Distr          Int,
    @Comp           TinyInt
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @Login      VarChar(100);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        IF @ID IS NOT NULL
            SELECT
                @Host_id = HostID, @Distr = DISTR, @Comp = COMP
            FROM dbo.ClientDistrView a WITH(NOEXPAND)
            WHERE ID = @ID;

        -- ToDo - хардкод
        IF @Host_Id = 1
            SET @Login = Cast(@Distr AS VarChar(20)) + CASE WHEN @Comp = 1 THEN '' ELSE '_' + Cast(@Comp AS VarChar(20)) END;

        SELECT [FileName], [CreateDateTime], [ProcessDateTime], [Login], [Password]
        FROM [Queue].[Online Passwords] AS OP
        WHERE [Login] = @Login
        ORDER BY [CreateDateTime] DESC;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Queue].[Online Passwords@Select] TO rl_online_passwords_r;
GO
