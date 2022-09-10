/****** Object:  UserDefinedFunction [SQL].[ObjectDefinition]    Script Date: 11.09.2022 0:58:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition]
(
    @Object_Id      Int,
    @ObjectType     VarChar(10) = NULL
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE
        @ObjectDefinition   NVarChar(Max),
        @Result             NVarChar(Max),
        @Parent_Object_Id   Int;

    IF @ObjectType IS NULL
        SELECT
            @ObjectType = O.[type],
            @Parent_Object_Id = O.[parent_object_id]
        FROM sys.objects AS O
        WHERE O.[object_id] = @Object_Id;
    ELSE
        SELECT
            @Parent_Object_Id = O.[parent_object_id]
        FROM sys.objects AS O
        WHERE O.[object_id] = @Object_Id;
        
    SET @Result = 'USE [' + DB_NAME() + ']' + '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
';
SELECT
    @Result = @Result + 'IF OBJECT_ID(''[' + S.[Schema] + '].[' + S.[Name] + ']'', ''' + S.[Type] + ''') IS NULL EXEC(''CREATE ' + T.[TypeFull] + ' [' + S.[Schema] + '].[' + S.[Name] + '] ' +
        CASE WHEN S.[Type] = 'TR' THEN ' ON [' + S.[TblSchema] + '].[' + Replace(S.[TblName], '_LAST_UPDATE', '') + '] AFTER INSERT,UPDATE,DELETE ' ELSE '' END +
            CASE
                WHEN S.[Type] = 'FN' THEN '() RETURNS Int AS BEGIN RETURN NULL END'
                WHEN S.[Type] = 'IF' THEN '() RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)'
                WHEN S.[Type] = 'TF' THEN '() RETURNS @output TABLE(Id Int) AS BEGIN RETURN END'
                ELSE ' AS SELECT 1'
            END + ''')
GO
'
FROM
(
    SELECT TOP (1) [TypeFull]
    FROM
    (
        SELECT
            [Type] = 'FN', [TypeFull] = 'FUNCTION'
        ---
        UNION ALL
        ---
        SELECT
            'TF', 'FUNCTION'
           ---
        UNION ALL
        ---
        SELECT
            'P', 'PROCEDURE'
          ---
        UNION ALL
        ---
        SELECT
            'TR', 'TRIGGER'
           ---
        UNION ALL
        ---
        SELECT
            'IF', 'FUNCTION'
        ---
        UNION ALL
        ---
        SELECT
            'V', 'VIEW'
    ) V([Type], [TypeFull])
    WHERE V.[Type] = @ObjectType
) AS T
CROSS APPLY
(
    SELECT
        [Type]      = @ObjectType,
        [Schema]    = Object_Schema_Name(@Object_Id),
        [Name]      = Object_Name(@Object_Id),
        [TblSchema] = Object_Schema_Name(@Parent_Object_Id),
        [TblName]   = Object_Name(@Parent_Object_Id)
) AS S

    IF @ObjectType = 'U'
        SET @ObjectDefinition = [SQL].[ObjectDefinition?Table](@Object_Id)
    ELSE IF @ObjectType = 'V'
        SET @ObjectDefinition = [SQL].[ObjectDefinition?View](@Object_Id);
    ELSE IF @ObjectType = 'SN'
        SET @ObjectDefinition = NULL--[SQL].[ObjectDefinition?Synonym]
    ELSE
        SET @ObjectDefinition = Object_Definition(@Object_Id);

    -- ToDO
    SET @ObjectDefinition = Replace(@ObjectDefinition, 'CREATE PROCEDURE',  'ALTER PROCEDURE');
    SET @ObjectDefinition = Replace(@ObjectDefinition, 'CREATE FUNCTION',   'ALTER FUNCTION');
    SET @ObjectDefinition = Replace(@ObjectDefinition, 'CREATE VIEW',       'ALTER VIEW');
    SET @ObjectDefinition = Replace(@ObjectDefinition, 'CREATE TRIGGER',    'ALTER TRIGGER');

    SET @Result = @Result + @ObjectDefinition;

    IF @Result LIKE '%END'
        SET @Result = @Result + Char(13) + Char(10);

    WHILE (CharIndex(' ' + Char(13) + Char(10), @Result) != 0)
        SET @Result = Replace(@Result, ' ' + Char(13) + Char(10), Char(13) + Char(10));

    WHILE (CharIndex('	' + Char(13) + Char(10), @Result) != 0)
        SET @Result = Replace(@Result, '	' + Char(13) + Char(10), Char(13) + Char(10));

    WHILE   (CharIndex(Char(10) + Char(13) + Char(10), @Result) != 0)
        AND (SubString(@Result, CharIndex(Char(10) + Char(13) + Char(10), @Result) - 1, 1) != Char(13))
        SET @Result = Replace(@Result, Char(10) + Char(13) + Char(10), Char(13) + Char(10) + Char(13) + Char(10));

    SET @Result = @Result + 'GO
';

    SET @Result = @Result + IsNull([SQL].[ObjectDefinition?Permissions](@Object_Id) + '
GO
', '');

    RETURN @Result;
END;
GO