USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Debug].[Executions@Clear]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Debug].[Executions@Clear]  AS SELECT 1')
GO
CREATE   PROCEDURE [Debug].[Executions@Clear]
    @Mode       VarChar(100) = 'AUTO'
    -- AUTO
    -- FULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE
		@ErrorMessage	NVarChar(2048),
		@ErrorSeverity	Int,
		@ErrorState		Int;

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
		SET @ErrorSeverity	= ERROR_SEVERITY();
		SET @ErrorState		= ERROR_STATE();


		SET @ErrorMessage =
			'Ошибка в процедуре "'+ IsNull(ERROR_PROCEDURE(), '') + '". ' +
								IsNull(ERROR_MESSAGE(), '') + ' (' +
								IsNull('№ ошибки: ' + Cast(ERROR_NUMBER() AS NVarChar(10)), '') +
								IsNull(' строка ' + Cast(ERROR_LINE() AS NVarChar(10)), '') + ')';

        RaisError(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
