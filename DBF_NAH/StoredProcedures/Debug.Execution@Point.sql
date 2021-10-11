USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Debug].[Execution@Point]
    @DebugContext   Xml,
    @Name           VarChar(128),
    @Params         Xml             = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Id             BigInt,
        @FinishDateTime DateTime;

    SET @Id         = @DebugContext.value('(/DEBUG/@Id)[1]', 'BigInt');

    INSERT INTO [Debug].[Executions:Point]([Execution_Id], [Row:Index], [StartDateTime], [Name])
    SELECT @Id, IsNull([Row:Index] + 1, 1), GetDate(), @Name
    FROM (SELECT [Null] = NULL) AS N
    OUTER APPLY
    (
        SELECT TOP (1)
            P.[Row:Index]
        FROM [Debug].[Executions:Point] AS P
        WHERE P.[Execution_Id] = @Id
        ORDER BY
            P.[Row:Index] DESC
    ) AS P;

    SELECT @Id = Scope_Identity();

    IF @Params IS NOT NULL BEGIN
        INSERT INTO [Debug].[Executions:Point:Params]([Id], [Row:Index], [Name], [Value])
        SELECT @Id, P.[Row:Index], P.[Name], P.[Value]
        FROM [Debug].[Execution:Params@Parse](@Params) P;
    END;
END;


GO
