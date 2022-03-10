USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Debug].[Executions@Clear]
    @Mode       VarChar(100) = 'AUTO'
    -- AUTO
    -- FULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Mode NOT IN ('AUTO', 'FULL')
            RaisError('@Mode NOT IN (''AUTO'', ''FULL'')', 16, 1);

        IF @Mode = 'AUTO' BEGIN
            DELETE
            FROM [Debug].[Executions:Start]
            WHERE
                [UserName] IN ('Автомат', 'AURA\denisov')
                OR
                [Object] IN ('[dbo].[CLIENT_MESSAGE_CHECK]', '[dbo].[CLIENT_MESSAGE_NOTIFY]')
                ;

            DELETE P
            FROM [Debug].[Executions:Start:Params] AS P
            LEFT JOIN [Debug].[Executions:Start] AS S ON P.[Id] = S.[Id]
            WHERE S.[Id] IS NULL;

            DELETE P
            FROM [Debug].[Executions:Point] AS P
            LEFT JOIN [Debug].[Executions:Start] AS S ON P.[Execution_Id] = S.[Id]
            WHERE S.[Id] IS NULL;

            DELETE P
            FROM [Debug].[Executions:Point:Params] AS P
            LEFT JOIN [Debug].[Executions:Start] AS S ON P.[Id] = S.[Id]
            WHERE S.[Id] IS NULL;

            DELETE F
            FROM [Debug].[Executions:Finish] AS F
            LEFT JOIN [Debug].[Executions:Start] AS S ON F.[Id] = S.[Id]
            WHERE S.[Id] IS NULL;
        END
        ELSE IF @Mode = 'FULL' BEGIN
            TRUNCATE TABLE [Debug].[Executions:Point:Params]
            TRUNCATE TABLE [Debug].[Executions:Start:Params]
            TRUNCATE TABLE [Debug].[Executions:Point]
            TRUNCATE TABLE [Debug].[Executions:Finish]
            TRUNCATE TABLE [Debug].[Executions:Start]
        END
        ELSE
            RaisError('Unknown @Mode', 16, 1);
    END TRY
    BEGIN CATCH
        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
