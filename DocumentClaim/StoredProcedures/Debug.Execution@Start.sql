USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Debug].[Execution@Start]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Debug].[Execution@Start]  AS SELECT 1')
GO
CREATE   PROCEDURE [Debug].[Execution@Start]
	@Proc_Id		Int,
	@Params			Xml,
	@DebugContext	Xml OUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    IF [Debug].[Execution@Enabled]() = 0
        RETURN;

    DECLARE
        @Id             BigInt,
        @StartDateTime  DateTime,
        @Object         VarChar(512),
        @UserName       VarChar(128),
        @HostName       VarChar(128);

    SET @StartDateTime  = GetDate();
    SET @Object         = '[' + Object_Schema_Name(@Proc_Id) + '].[' + Object_Name(@Proc_Id) + ']';
    SET @UserName       = Original_Login();
    SET @HostName       = Host_Name();

    INSERT INTO [Debug].[Executions:Start]([StartDateTime], [Object], [UserName], [HostName])
    VALUES(@StartDateTime, @Object, @UserName, @HostName);

    SELECT @Id = Scope_Identity();

    SET @DebugContext =
        (
            SELECT
                [Id]            = @Id,
                [StartDateTime] = @StartDateTime
            FOR XML RAW('DEBUG'), TYPE
        );

    IF @Params IS NOT NULL BEGIN
        INSERT INTO [Debug].[Executions:Start:Params]([Id], [Row:Index], [Name], [Value])
        SELECT @Id, P.[Row:Index], P.[Name], P.[Value]
        FROM [Debug].[Execution:Params@Parse](@Params) P;
    END;
END;
GO
