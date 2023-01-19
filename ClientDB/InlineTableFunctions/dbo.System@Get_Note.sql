USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[System@Get?Note]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[System@Get?Note] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[System@Get?Note]
(
    @System_Id      SmallInt,
    @DistrType_Id   SmallInt
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        [Note], [NoteWTitle]
    FROM
    (
        SELECT
            [Index] = 1,
            [Note],
            [NoteWTitle]
        FROM [dbo].[SystemNote:DistrType] AS S
        WHERE   S.[System_Id] = @System_Id
            AND S.[DistrType_Id] = @DistrType_Id

        UNION ALL

        SELECT
            [Index] = 2,
            [NOTE],
            [NOTE_WTITLE]
        FROM [dbo].[SystemNote] AS S
        WHERE   S.[ID_SYSTEM] = @System_Id
    ) AS S
    ORDER BY
        [Index]
)
GO
