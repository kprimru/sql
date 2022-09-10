/****** Object:  UserDefinedFunction [SQL].[ObjectDefinition?Table]    Script Date: 11.09.2022 0:57:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition?Table]
(
    @Object_Id      Int
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE
        @MaxColumnLen               Int,
        @MaxTypeLen                 Int,
        @MaxIdentityAndCollateLen   Int,
        @DatabaseCollation          VarChar(256),
        @Result                     NVarChar(Max);

    DECLARE @Columns Table
    (
        [Id]            Int             NOT NULL,
        [Name]          VarChar(256)    NOT NULL,
        [Type]          VarChar(256)    NOT NULL,
        [Collation]     VarChar(256)    NOT NULL,
        [Identity]      VarChar(256)    NOT NULL,
        [Nullable]      VarChar(256)    NOT NULL,
        [Computed]      VarChar(512)    NOT NULL
        PRIMARY KEY CLUSTERED([Id])
    );

    SELECT @DatabaseCollation = D.collation_name
    FROM sys.databases AS D
    WHERE database_id = DB_ID();

    INSERT INTO @Columns
    SELECT
        C.[column_id], C.[name], T.[Type_Name],
        CASE WHEN c.collation_name IS NOT NULL AND c.collation_name != @DatabaseCollation THEN 'Collate ' + c.collation_name ELSE '' END,
        CASE WHEN c.is_identity = 1 THEN 'Identity(1,1)' ELSE '' END,
        CASE c.is_nullable WHEN 1 THEN '    NULL' ELSE 'NOT NULL' END,
        CASE WHEN CC.name IS NULL THEN '' ELSE ' AS ' + CC.definition + ' ' + CASE CC.is_persisted WHEN 1 THEN 'PERSISTED' ELSE '' END END
    FROM sys.columns AS C
    INNER JOIN sys.types AS ST ON C.[user_type_id] = ST.[user_type_id]
    CROSS APPLY
    (
        SELECT [Type_Name] =
                CASE ST.[name]
                    WHEN 'int' THEN 'Int'
                    WHEN 'varchar' THEN 'VarChar'
                    WHEN 'nvarchar' THEN 'NVarChar'
                    WHEN 'money' THEN 'Money'
                    WHEN 'smallint' THEN 'SmallInt'
                    WHEN 'datetime' THEN 'DateTime'
                    WHEN 'smalldatetime' THEN 'SmallDateTime'
                    WHEN 'tinyint' THEN 'TinyInt'
                    WHEN 'bit' THEN 'Bit'
                    WHEN 'uniqueidentifier' THEN 'UniqueIdentifier'
                    ELSE ST.[name]
                END
                +
                CASE
                    WHEN ST.[name] IN ('Char', 'VarChar', 'NChar', 'NVarChar') THEN
                        '(' + CASE WHEN C.[max_length] = -1 THEN 'Max' ELSE Cast(C.[max_length] AS VarChar(10)) END + ')'
                    ELSE ''
                END
    ) AS T
    LEFT JOIN sys.computed_columns AS CC ON CC.object_id = C.object_id AND CC.column_id = C.column_id
    WHERE C.[Object_Id] = @Object_Id;

    SELECT
        @MaxColumnLen   = Max(Len([Name])),
        @MaxTypeLen     = Max(Len([Type])),
        @MaxIdentityAndCollateLen = Max(Len([Identity]) + Len([Collation]))
    FROM @Columns;

    SET @Result = 'CREATE TABLE [' + Object_Schema_Name(@Object_Id) + '].[' + Object_Name(@Object_Id) + ']
('

    SELECT @Result = @Result + '
        [' + C.[name] + ']' 
            + Replicate(' ', @MaxColumnLen  - Len(C.[Name]) + 3)
            +
            CASE
                WHEN [Computed] != '' THEN [Computed]
                ELSE
                    C.[Type]
                    + Replicate(' ', @MaxTypeLen    - Len(C.[Type]) + 3) + 
                    + C.[Collation]
                    + C.[Identity]
                    + Replicate(' ', @MaxIdentityAndCollateLen    - Len(C.[Collation]) - Len(C.[Identity]) + 3) + 
                    + C.[Nullable]
            END
            -- default
            
        + ','
    FROM @Columns AS C
    ORDER BY C.[id]

    SELECT @Result = @Result + '
        CONSTRAINT [' + name + '] PRIMARY KEY ' + I.[type_desc] + ' (' +IC.[IndexColumns] + ')'
    FROM sys.indexes AS I
    CROSS APPLY
    (
        SELECT
            [IndexColumns] = 
                Reverse(Stuff(Reverse((
                    SELECT '[' + C.name + ']' + ','
                    FROM sys.index_columns AS IC
                    INNER JOIN sys.columns AS C ON C.object_id = I.object_id AND C.column_id = IC.column_id
                    WHERE IC.[object_id] = I.object_id
                        AND IC.[index_id] = I.[index_id]
                    ORDER BY IC.[index_column_id] FOR XML PATH('')
                )), 1, 1, ''))
    ) AS IC
    WHERE I.object_Id = @Object_id
        AND I.is_primary_key = 1;

    SELECT @Result = @Result + ',
        CONSTRAINT [' + FK.[name] + '] FOREIGN KEY  ([' + PC.name + ']) REFERENCES [' + Object_schema_name(T.Object_id) + '].[' + Object_Name(T.Object_id) + '] ([' + RC.name + '])'
    FROM sys.foreign_keys AS FK
    INNER JOIN sys.tables AS T ON FK.referenced_object_id = T.object_id
    INNER JOIN sys.foreign_key_columns AS FKC ON FKC.constraint_object_id = FK.object_id
    INNER JOIN sys.columns AS PC ON PC.object_id = FKC.parent_object_id AND PC.column_id = FKC.parent_column_id
    INNER JOIN sys.columns AS RC ON RC.object_id = FKC.referenced_object_id AND RC.column_id = FKC.referenced_column_id
    WHERE FK.parent_object_id = @object_id;

    -- Check constraint
    SET @Result = @Result + '
);
'

    SET @Result = @Result + IsNull('GO
' + [SQL].[ObjectDefinition?Indexes](@Object_Id) + '
', '');

    RETURN @Result;
END;
GO