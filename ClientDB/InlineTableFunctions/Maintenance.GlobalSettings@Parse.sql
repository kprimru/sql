USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalSettings@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalSettings@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Maintenance].[GlobalSettings@Parse]
(
    @Data Xml
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Name]          = V.[Name],
        [Value]         = V.[Value],
        [DataType]      = V.[DataType]
    FROM @Data.nodes('/Settings/Setting') AS n(v)
    CROSS APPLY
    (
        SELECT
            [Name]          = v.value('@Name[1]',         'VarChar(128)'),
            [Value]         = v.value('@Value[1]',        'VarChar(256)'),
            [DataType]      = v.value('@DataType[1]',     'VarChar(128)')
    ) AS V
)GO
