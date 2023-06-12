USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[Income@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Raw].[Income@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Raw].[Income@Parse]
(
    @Data Xml
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Date]      = Convert(SmallDateTime, i.[Date], 104),
        [Inn]       = i.[Inn],
        [Name]      = i.[Name],
        [Purpose]   = i.[Purpose],
        [Num]       = i.[Num],
        [Price]     = Convert(Money, Replace(i.[Price], ',', '.'))
    FROM
    (
        SELECT
            [Date]      = i.value('@Date[1]',     'VarChar(20)'),
            [Inn]       = i.value('@Inn[1]',      'VarChar(20)'),
            [Name]      = i.value('@Name[1]',     'VarChar(256)'),
            [Purpose]   = i.value('@Purpose[1]',  'VarChar(Max)'),
            [Num]       = i.value('@Num[1]',      'VarChar(20)'),
            [Price]     = i.value('@Price[1]',    'VarChar(20)')
        FROM @Data.nodes('/ROOT/ITEM') AS r(i)
    ) AS i
    WHERE [Date] != ''
)
GO
