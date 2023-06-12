/****** Object:  UserDefinedFunction [SQL].[ObjectDefinition?Indexes]    Script Date: 11.09.2022 0:58:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition?Indexes]
(
    @Object_Id      Int
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE @Result NVarChar(Max);

    SET @Result = N'';

    SELECT
        @Result = @Result + 'CREATE' + 
                CASE WHEN I.[is_unique] = 1 THEN ' UNIQUE' ELSE '' END +
                CASE WHEN I.[type] = 1 THEN ' CLUSTERED' ELSE ' NONCLUSTERED' END +
                ' INDEX [' + I.[name] + '] ON [' + Object_schema_name(@Object_id) + '].[' + Object_name(@Object_id) + '] (' + C.[Columns] + ')' +
                                    CASE WHEN IC.[IncludedColumns] IS NOT NULL THEN ' INCLUDE (' + IC.[IncludedColumns] + ')' ELSE '' END +
									-- TODO: почему-то не генерируется скрипт для фильтрованных индексов
									--CASE WHEN I.[filter_definition] IS NOT NULL THEN ' WHERE ' + I.[filter_definition] + '' ELSE '' END + 
				';' + Char(10)
    FROM [sys].[indexes]        I
    INNER JOIN [sys].[objects]  O ON I.[object_id] = O.[object_id]
    INNER JOIN [sys].[schemas]  S ON S.[schema_id] = O.[schema_id]
    OUTER APPLY
    (
        SELECT [Columns] = REVERSE(STUFF(REVERSE(
                (
                    SELECT '[' + C.[name] + ']' + CASE WHEN IC.[is_descending_key] = 0 THEN ' ASC' ELSE ' DESC' END + ', '
                    FROM [sys].[index_columns] IC
                    INNER JOIN [sys].[columns] C ON C.[column_id] = IC.[column_id]
                    WHERE   IC.[object_id] = I.[object_id]
                        AND IC.[index_id] = I.[index_id]
                        AND IC.[is_included_column] = 0
                        AND C.[object_id] = O.[object_id]
                    ORDER BY IC.[key_ordinal] FOR XML PATH('')
                )), 1, 2, ''))
    ) AS C
    OUTER APPLY
    (
        SELECT
            [IncludedColumns] = REVERSE(STUFF(REVERSE(
                (
                    SELECT '[' + C.[name] + '], '
                    FROM [sys].[index_columns] IC
                    INNER JOIN [sys].[columns] C ON C.[column_id] = IC.[column_id]
                    WHERE   IC.[object_id] = I.[object_id]
                        AND IC.[index_id] = I.[index_id]
                        AND IC.[is_included_column] = 1
                        AND C.[object_id] = O.[object_id]
                    ORDER BY IC.[key_ordinal] FOR XML PATH('')
                )), 1, 2, ''))
    ) AS IC
    WHERE I.[object_id] = @object_id
        AND I.[type] != 0
        AND I.[is_primary_key] = 0
    ORDER BY
        CASE I.[type] WHEN 1 THEN 0 ELSE 1 END, I.[name];

    IF @Result != ''
        SET @Result = Left(@Result, Len(@Result) - 1)
    ELSE
        SET @Result = NULL;

    RETURN @Result;
END;
GO