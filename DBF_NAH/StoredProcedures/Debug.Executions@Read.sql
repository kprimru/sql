USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Debug].[Executions@Read]
    @MaxResultCount Int             = 20,
    @Object         NVarChar(512)   = NULL,
    @Exec_Id        BigInt          = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exec_Result Table
    (
        [Identity]  SmallInt    Identity(1,1)   NOT NULL,
        [Type]      TinyInt                     NOT NULL,
        [Row:Index] TinyInt                     NOT NULL,
        [Name]      VarChar(128),
        [DateTime]  DateTime,
        [Error]     VarChar(512),
        PRIMARY KEY CLUSTERED ([Identity])
    );

    BEGIN TRY
        IF @Exec_Id IS NOT NULL AND @Object IS NOT NULL
            RaisError('@Exec_Id IS NOT NULL AND @Object IS NOT NULL', 16, 1);

        IF @Exec_Id IS NULL AND @Object IS NULL
            RaisError('@Exec_Id IS NULL AND @Object IS NULL', 16, 1);

        IF @Object IS NOT NULL BEGIN
            SELECT TOP (@MaxResultCount)
                S.[Id], S.[Object], S.[UserName], S.[HostName],
                S.[StartDateTime], F.[FinishDateTime],
                [Duration] = DateDiff(MilliSecond, S.[StartDateTime], F.[FinishDateTime]),
                F.[Error]
            FROM [Debug].[Executions:Start]         AS S WITH (NOLOCK)
            LEFT JOIN [Debug].[Executions:Finish]   AS F WITH (NOLOCK) ON S.[Id] = F.[Id]
            WHERE S.[Object] = @Object
            ORDER BY [Id] DESC;

        END ELSE IF @Exec_Id IS NOT NULL BEGIN

            INSERT INTO @Exec_Result
            SELECT [Type], [Row:Index], [Name], [DateTime], [Error]
            FROM
            (
                SELECT
                    [Type]      = 1,
                    [Row:Index] = 1,
                    [Name]      = 'Execution Start',
                    [DateTime]  = S.[StartDateTime],
                    [Error]     = NULL
                FROM [Debug].[Executions:Start] AS S WITH (NOLOCK)
                WHERE [Id] = @Exec_Id

                UNION ALL

                SELECT
                    [Type]      = 2,
                    [Row:Index] = P.[Row:Index],
                    [Name]      = P.[Name],
                    [DateTime]  = P.[StartDateTime],
                    [Error]     = NULL
                FROM [Debug].[Executions:Point] AS P WITH (NOLOCK)
                WHERE [Execution_Id] = @Exec_Id

                UNION ALL

                SELECT
                    [Type]      = 3,
                    [Row:Index] = 1,
                    [Name]      = 'Execution Finish',
                    [DateTime]  = F.[FinishDateTime],
                    [Error]     = F.[Error]
                FROM [Debug].[Executions:Finish] AS F WITH (NOLOCK)
                WHERE [Id] = @Exec_Id
            ) AS E
            ORDER BY [Type], [Row:Index];

            SELECT
                R.[Name], R.[DateTime],
                [Duration] = DateDiff(MilliSecond, P.[DateTime], R.[DateTime]),
                R.[Error]
            FROM @Exec_Result AS R
            OUTER APPLY
            (
                SELECT TOP (1)
                    [DateTime]
                FROM @Exec_Result AS P
                WHERE P.[Identity] = R.[Identity] - 1
            ) AS P
            ORDER BY [Identity];
        END;
    END TRY
    BEGIN CATCH
        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
