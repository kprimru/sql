--USE [master];

DECLARE
    @Src        NVarChar(256),
    @Dst        NVarChar(256);

SET @Src = '[PC275-SQL\ALPHA].[ClientDB]';
SET @Dst = '[PC275-SQL\GAMMA].[ClientNahDB]';

DECLARE @SrcSchemas Table
(
    [Schema]    SysName     NOT NULL PRIMARY KEY CLUSTERED
);
DECLARE @DstSchemas Table
(
    [Schema]    SysName     NOT NULL PRIMARY KEY CLUSTERED
);

DECLARE @SrcTables Table
(
    [Schema]    SysName     NOT NULL,
    [Table]     SysName     NOT NULL,
    PRIMARY KEY CLUSTERED ([Schema], [Table])
);

DECLARE @DstTables Table
(
    [Schema]    SysName     NOT NULL,
    [Table]     SysName     NOT NULL,
    PRIMARY KEY CLUSTERED ([Schema], [Table])
);

DECLARE @SrcColumns Table
(
    [Schema]        		SysName,
    [Table]         		SysName,
    [Column]        		SysName,
    [ColumnIndex]   		Int,
    [Type]          		VarChar(256),
    [IsNull]        		Bit,
    [Computed:Formula]		VarChar(Max),
    [Computed:Persisted]	Bit,
    [Collation]				SysName         NULL,
    PRIMARY KEY CLUSTERED ([Schema], [Table], [Column])
);

DECLARE @DstColumns Table
(
    [Schema]        		SysName,
    [Table]         		SysName,
    [Column]        		SysName,
    [ColumnIndex]   		Int,
    [Type]          		VarChar(256),
    [IsNull]        		Bit,
    [Computed:Formula]		VarChar(Max),
    [Computed:Persisted]	Bit,
    [Collation]				SysName         NULL,
    PRIMARY KEY CLUSTERED ([Schema], [Table], [Column])
);

DECLARE @SrcViews Table
(
    [Schema]        SysName,
    [Name]          SysName,
    [Definition]    NVarChar(Max),
    PRIMARY KEY CLUSTERED([Schema], [Name])
);

DECLARE @DstViews Table
(
    [Schema]        SysName,
    [Name]          SysName,
    [Definition]    NVarChar(Max),
    PRIMARY KEY CLUSTERED([Schema], [Name])
);

DECLARE @SrcIndexes Table
(
    [Schema]                SysName,
    [Table]                 SysName,
    [Name]                  SysName,
    [Columns]               VarChar(Max),
    [Included]              VarChar(Max),
    [IsClustered]           Bit,
    [IsPrimaryKey]          Bit,
    [IsUnique]              Bit,
    [IsUniqueConstraint]    Bit
);

DECLARE @DstIndexes Table
(
    [Schema]                SysName,
    [Table]                 SysName,
    [Name]                  SysName,
    [Columns]               VarChar(Max),
    [Included]              VarChar(Max),
    [IsClustered]           Bit,
    [IsPrimaryKey]          Bit,
    [IsUnique]              Bit,
    [IsUniqueConstraint]    Bit
);

DECLARE @SrcRouties Table
(
    [Schema]        SysName,
    [Name]          SysName,
    [Type]          VarChar(10),
    [Definition]    NVarChar(Max),
    PRIMARY KEY CLUSTERED([Schema], [Name])
);

DECLARE @DstRouties Table
(
    [Schema]        SysName,
    [Name]          SysName,
    [Type]          VarChar(10),
    [Definition]    NVarChar(Max),
    PRIMARY KEY CLUSTERED([Schema], [Name])
);

DECLARE @SrcRoles Table
(
    [Name]          SysName,
    [Members]		NVarCHar(Max)
    PRIMARY KEY CLUSTERED([Name])
);

DECLARE @DstRoles Table
(
    [Name]          SysName,
    [Members]		NVarCHar(Max)
    PRIMARY KEY CLUSTERED([Name])
);


INSERT INTO @SrcSchemas
EXEC ('SELECT [name] FROM ' + @Src + '.[sys].[schemas]');

INSERT INTO @DstSchemas
EXEC ('SELECT [name] FROM ' + @Dst + '.[sys].[schemas]');

INSERT INTO @SrcTables
EXEC ('
SELECT S.[name], T.[name] FROM ' + @Src + '.[sys].[tables]         T
INNER JOIN ' + @Src + '.[sys].[schemas]  S ON T.[schema_id] = S.[schema_id]');

INSERT INTO @DstTables
EXEC ('
SELECT S.[name], T.[name] FROM ' + @Dst + '.[sys].[tables]         T
INNER JOIN ' + @Dst + '.[sys].[schemas]  S ON T.[schema_id] = S.[schema_id]');

INSERT INTO @SrcColumns
EXEC ('
SELECT
    S.[name], T.[name], C.[name], C.[column_id],
    CASE
        WHEN ST.[name] IN (''VarChar'') THEN ST.[name] + ''('' + CASE WHEN C.[max_length] = -1 THEN ''Max'' ELSE Cast(C.[max_length] As VarChar(10)) END + '')''
        WHEN ST.[name] IN (''NVarChar'') THEN ST.[name] + ''('' + CASE WHEN C.[max_length] = -1 THEN ''Max'' ELSE Cast(C.[max_length] / 2 As VarChar(10)) END + '')''
        WHEN ST.[name] IN (''Decimal'', ''Numeric'') THEN ST.[name] + ''('' + Cast(C.[precision] As VarChar(10)) + '', '' + Cast(C.[scale] As VarChar(10)) + '')''
        ELSE ST.[name]
    END, c.[is_nullable], cc.[definition], cc.[is_persisted], c.[collation_name]
FROM ' + @Src +'.[sys].[columns]        		C
INNER JOIN ' + @Src +'.[sys].[tables]   		T   ON C.[object_id] = T.[object_id]
INNER JOIN ' + @Src +'.[sys].[schemas]  		S   ON S.[schema_id] = T.[schema_id]
INNER JOIN ' + @Src +'.[sys].[types]    		ST  ON ST.[user_type_id] = C.[system_type_id]
LEFT JOIN ' + @Src + '.[sys].[computed_columns]	CC	ON CC.[object_id] = T.[object_id] AND CC.[name] = C.[name];');

INSERT INTO @DstColumns
EXEC ('
SELECT
    S.[name], T.[name], C.[name], C.[column_id],
    CASE
        WHEN ST.[name] IN (''VarChar'') THEN ST.[name] + ''('' + CASE WHEN C.[max_length] = -1 THEN ''Max'' ELSE Cast(C.[max_length] As VarChar(10)) END + '')''
        WHEN ST.[name] IN (''NVarChar'') THEN ST.[name] + ''('' + CASE WHEN C.[max_length] = -1 THEN ''Max'' ELSE Cast(C.[max_length] / 2 As VarChar(10)) END + '')''
        WHEN ST.[name] IN (''Decimal'', ''Numeric'') THEN ST.[name] + ''('' + Cast(C.[precision] As VarChar(10)) + '', '' + Cast(C.[scale] As VarChar(10)) + '')''
        ELSE ST.[name]
    END, c.[is_nullable], cc.[definition], cc.[is_persisted], c.[collation_name]
FROM ' + @Dst +'.[sys].[columns]        C
INNER JOIN ' + @Dst +'.[sys].[tables]   		T   ON C.[object_id] = T.[object_id]
INNER JOIN ' + @Dst +'.[sys].[schemas]  		S   ON S.[schema_id] = T.[schema_id]
INNER JOIN ' + @Dst +'.[sys].[types]    		ST  ON ST.[user_type_id] = C.[system_type_id]
LEFT JOIN ' + @Dst + '.[sys].[computed_columns]	CC	ON CC.[object_id] = T.[object_id] AND CC.[name] = C.[name];');

INSERT INTO @SrcViews
EXEC ('SELECT S.[name], V.[name], M.[definition]
FROM ' + @Src + '.[sys].[views]          V
INNER JOIN ' + @Src + '.[sys].[schemas]  S ON S.[schema_id] = V.[schema_id]
INNER JOIN ' + @Src + '.[sys].[sql_modules] M ON M.[object_id] = V.[object_id];');

INSERT INTO @DstViews
EXEC ('SELECT S.[name], V.[name], M.[definition]
FROM ' + @Dst + '.[sys].[views]          V
INNER JOIN ' + @Dst + '.[sys].[schemas]  S ON S.[schema_id] = V.[schema_id]
INNER JOIN ' + @Dst + '.[sys].[sql_modules] M ON M.[object_id] = V.[object_id];');

INSERT INTO @SrcRouties
EXEC ('SELECT S.[name], O.[name], O.[type], M.[definition]
FROM ' + @Src + '.[sys].[objects] O
INNER JOIN ' + @Src + '.[sys].[schemas] S ON O.[schema_id] = S.[schema_id]
INNER JOIN ' + @Src + '.[sys].[sql_modules] M ON M.[object_id] = O.[object_id]
WHERE O.[type] IN (''FN'', ''TF'', ''P'', ''TR'', ''IF'');');

INSERT INTO @DstRouties
EXEC ('SELECT S.[name], O.[name], O.[type], M.[definition]
FROM ' + @Dst + '.[sys].[objects] O
INNER JOIN ' + @Dst + '.[sys].[schemas] S ON O.[schema_id] = S.[schema_id]
INNER JOIN ' + @Dst + '.[sys].[sql_modules] M ON M.[object_id] = O.[object_id]
WHERE O.[type] IN (''FN'', ''TF'', ''P'', ''TR'', ''IF'');');

INSERT INTO @SrcRoles
EXEC('SELECT R.[name],
	REVERSE(STUFF(REVERSE(
		(
			SELECT ''EXEC sp_addrolemember '''''' + r.[name] + '''''', '''''' + u.[name] + '''''';''
			FROM ' + @Src + '.sys.database_role_members rm
			INNER JOIN ' + @Src + '.sys.database_principals u ON rm.member_principal_id = u.principal_id
			WHERE r.principal_id = rm.role_principal_id
			FOR XML PATH('''')
		)
		), 1, 1, ''''))
FROM ' + @Src + '.sys.database_principals R
WHERE type = ''R'';');

INSERT INTO @DstRoles
EXEC('SELECT R.[name],
	REVERSE(STUFF(REVERSE(
		(
			SELECT ''EXEC sp_droprolemember '''''' + r.[name] + '''''', '''''' + u.[name] + '''''';''
			FROM ' + @Dst + '.sys.database_role_members rm
			INNER JOIN ' + @Dst + '.sys.database_principals u ON rm.member_principal_id = u.principal_id
			WHERE r.principal_id = rm.role_principal_id
			FOR XML PATH('''')
		)
		), 1, 1, ''''))
FROM ' + @Dst + '.sys.database_principals R
WHERE type = ''R'';');

INSERT INTO @SrcIndexes
EXEC ('SELECT
    S.[name], O.[name], I.[name],
    C.[Columns], IC.[IncludedColumns],
    [IsClustered] = CASE WHEN I.[type] = 1 THEN 1 WHEN I.[type] = 2 THEN 0 ELSE NULL END,
    I.[is_primary_key],
    I.[is_unique],
    I.[is_unique_constraint]
FROM ' + @Src + '.[sys].[indexes]        I
INNER JOIN ' + @Src + '.[sys].[objects]  O ON I.[object_id] = O.[object_id]
INNER JOIN ' + @Src + '.[sys].[schemas]  S ON S.[schema_id] = O.[schema_id]
OUTER APPLY
(
    SELECT [Columns] = REVERSE(STUFF(REVERSE(
            (
                SELECT ''['' + C.[name] + '']'' + CASE WHEN IC.[is_descending_key] = 0 THEN '' ASC'' ELSE '' DESC'' END + '', ''
                FROM ' + @Src + '.[sys].[index_columns] IC
                INNER JOIN ' + @Src + '.[sys].[columns] C ON C.[column_id] = IC.[column_id]
                WHERE   IC.[object_id] = I.[object_id]
                    AND IC.[index_id] = I.[index_id]
                    AND IC.[is_included_column] = 0
                    AND C.[object_id] = O.[object_id]
                ORDER BY IC.[key_ordinal] FOR XML PATH('''')
            )), 1, 2, ''''))
) AS C
OUTER APPLY
(
    SELECT
        [IncludedColumns] = REVERSE(STUFF(REVERSE(
            (
                SELECT ''['' + C.[name] + ''], ''
                FROM ' + @Src + '.[sys].[index_columns] IC
                INNER JOIN ' + @Src + '.[sys].[columns] C ON C.[column_id] = IC.[column_id]
                WHERE   IC.[object_id] = I.[object_id]
                    AND IC.[index_id] = I.[index_id]
                    AND IC.[is_included_column] = 1
                    AND C.[object_id] = O.[object_id]
                ORDER BY IC.[key_ordinal] FOR XML PATH('''')
            )), 1, 2, ''''))
) AS IC
WHERE I.[type] != 0');

INSERT INTO @DstIndexes
EXEC ('SELECT
    S.[name], O.[name], I.[name],
    C.[Columns], IC.[IncludedColumns],
    [IsClustered] = CASE WHEN I.[type] = 1 THEN 1 WHEN I.[type] = 2 THEN 0 ELSE NULL END,
    I.[is_primary_key],
    I.[is_unique],
    I.[is_unique_constraint]
FROM ' + @Dst + '.[sys].[indexes]        I
INNER JOIN ' + @Dst + '.[sys].[objects]  O ON I.[object_id] = O.[object_id]
INNER JOIN ' + @Dst + '.[sys].[schemas]  S ON S.[schema_id] = O.[schema_id]
OUTER APPLY
(
    SELECT [Columns] = REVERSE(STUFF(REVERSE(
            (
                SELECT ''['' + C.[name] + '']'' + CASE WHEN IC.[is_descending_key] = 0 THEN '' ASC'' ELSE '' DESC'' END + '', ''
                FROM ' + @Dst + '.[sys].[index_columns] IC
                INNER JOIN ' + @Dst + '.[sys].[columns] C ON C.[column_id] = IC.[column_id]
                WHERE   IC.[object_id] = I.[object_id]
                    AND IC.[index_id] = I.[index_id]
                    AND IC.[is_included_column] = 0
                    AND C.[object_id] = O.[object_id]
                ORDER BY IC.[key_ordinal] FOR XML PATH('''')
            )), 1, 2, ''''))
) AS C
OUTER APPLY
(
    SELECT
        [IncludedColumns] = REVERSE(STUFF(REVERSE(
            (
                SELECT ''['' + C.[name] + ''], ''
                FROM ' + @Dst + '.[sys].[index_columns] IC
                INNER JOIN ' + @Dst + '.[sys].[columns] C ON C.[column_id] = IC.[column_id]
                WHERE   IC.[object_id] = I.[object_id]
                    AND IC.[index_id] = I.[index_id]
                    AND IC.[is_included_column] = 1
                    AND C.[object_id] = O.[object_id]
                ORDER BY IC.[key_ordinal] FOR XML PATH('''')
            )), 1, 2, ''''))
) AS IC
WHERE I.[type] != 0');

-- схемы
--/*
IF EXISTS(SELECT * FROM @SrcSchemas S FULL JOIN @DstSchemas D ON S.[Schema] = D.[Schema] WHERE S.[Schema] IS NULL OR D.[Schema] IS NULL)
SELECT
    [Schema]    = IsNull(S.[Schema], D.[Schema]),
    [SQL]       =   CASE
                        WHEN S.[Schema] IS NOT NULL THEN 'IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = ''' + S.[Schema] + ''') EXEC(''CREATE SCHEMA [' + S.[Schema] + ']'');'
                        WHEN D.[Schema] IS NOT NULL THEN 'IF EXISTS(SELECT * FROM sys.schemas WHERE name = ''' + D.[Schema] + ''') DROP SCHEMA [' + D.[Schema] + '];'
                    END
FROM @SrcSchemas        S
FULL JOIN @DstSchemas   D ON S.[Schema] = D.[Schema]
WHERE S.[Schema] IS NULL OR D.[Schema] IS NULL
ORDER BY IsNull(S.[Schema], D.[Schema]);
--*/

-- таблицы
--/*
IF EXISTS(SELECT * FROM @SrcTables S FULL JOIN @DstTables D ON S.[Schema] = D.[Schema] AND S.[Table] = D.[Table] WHERE S.[Table] IS NULL OR D.[Table] IS NULL)
SELECT
    [Table] = '[' + IsNull(S.[Schema], D.[Schema]) + '].[' + IsNull(S.[Table], D.[Table]) + ']',
    [SQL]   =   CASE
                    WHEN S.[Schema] IS NOT NULL THEN 'IF Object_Id(''[' + S.[Schema] + '].[' + S.[Table] + ']'', ''U'') IS NULL BEGIN CREATE TABLE ... END;'
                    WHEN D.[Schema] IS NOT NULL THEN 'IF Object_Id(''[' + D.[Schema] + '].[' + D.[Table] + ']'', ''U'') IS NOT NULL BEGIN DROP TABLE [' + D.[Schema] + '].[' + D.[Table] + '] END;'
                END
FROM @SrcTables         S
FULL JOIN @DstTables    D ON S.[Schema] = D.[Schema] AND S.[Table] = D.[Table]
WHERE S.[Table] IS NULL OR D.[Table] IS NULL
ORDER BY IsNull(S.[Schema], D.[Schema]), IsNull(S.[Table], D.[Table]);
--*/

-- удялем колонки, если нет целиком таблиц для них
DELETE S
FROM @SrcColumns S
WHERE NOT EXISTS
    (
        SELECT *
        FROM @DstTables D
        WHERE D.[Schema] = S.[Schema]
            AND D.[Table] = S.[Table]
    );

DELETE D
FROM @DstColumns D
WHERE NOT EXISTS
    (
        SELECT *
        FROM @SrcTables S
        WHERE D.[Schema] = S.[Schema]
            AND D.[Table] = S.[Table]
    );

-- ToDo завязаться на database collation
UPDATE @SrcColumns
SET [Collation] = NULL
WHERE [Collation] = 'Cyrillic_General_CI_AS';

UPDATE @DstColumns
SET [Collation] = NULL
WHERE [Collation] = 'Cyrillic_General_CI_AS';

-- колонки
--/*
IF EXISTS (SELECT * FROM @SrcColumns S FULL JOIN @DstColumns D ON S.[Schema] = D.[Schema] AND S.[Table] = D.[Table] AND S.[Column] = D.[Column] WHERE S.[Column] IS NULL OR D.[Column] IS NULL OR S.[ColumnIndex] != D.[ColumnIndex] OR S.[Type] != D.[Type] OR S.[IsNull] != D.[IsNull] OR (IsNull(S.[Collation], '') != IsNull(D.[Collation], '')))
SELECT
    [Table]         = '[' + IsNull(S.[Schema], D.[Schema]) + '].[' + IsNull(S.[Table], D.[Table]) + ']',
    [Column]        = IsNull(S.[Column], D.[Column]),
    [ColumnIndex]   = CASE WHEN S.[ColumnIndex] != D.[ColumnIndex] THEN Cast(D.[ColumnIndex] AS VarChar(10)) + ' -> ' + Cast(S.[ColumnIndex] AS VarChar(10)) ELSE NULL END,
    [Type]          = CASE WHEN S.[Type] != D.[Type] THEN D.[Type] + ' -> ' + S.[Type] ELSE NULL END,
    [IsNull]        = CASE WHEN S.[IsNull] != D.[IsNull] THEN Cast(D.[IsNull] AS VarChar(10)) + ' -> ' + Cast(S.[IsNull] AS VarChar(10)) ELSE NULL END,
    [Computed:Furmula] = CASE WHEN  IsNull(S.[Computed:Formula], '') != IsNull(D.[Computed:Formula], '') THEN IsNull(D.[Computed:Formula], '') + ' -> ' + IsNull(S.[Computed:Formula], '') ELSE NULL END,
    [Computed:Persisted] = CASE WHEN IsNull(S.[Computed:Persisted], 0) != IsNull(D.[Computed:Persisted], 0) THEN Cast(IsNull(D.[Computed:Persisted], 0) AS VarChar(10)) + ' -> ' + Cast(IsNull(S.[Computed:Persisted], 0) AS VarChar(10)) ELSE NULL END,
    [Collation]     = CASE WHEN IsNull(S.[Collation], '') != IsNull(D.[Collation], '') THEN IsNull(D.[Collation], '') + ' -> ' + IsNull(S.[Collation], '') ELSE NULL END,
    [SQL]           =   CASE
                            -- Если новая колонка
                            WHEN D.[Column] IS NULL THEN
                                'IF COL_LENGTH(''[' + S.[Schema] + '].[' + S.[Table] + ']'', ''' + S.[Column] + ''') IS NULL BEGIN ALTER TABLE [' + S.[Schema] + '].[' + S.[Table] + '] ADD [' + S.[Column] + '] ' + S.[Type] + IsNull(' Collate ' + S.[Collation], '') + CASE WHEN S.[IsNull] = 1 THEN ' NULL' ELSE ' NOT NULL' END + ' END'
                            -- удаленная колонка
                            WHEN S.[Column] IS NULL THEN
                                'IF COL_LENGTH(''[' + D.[Schema] + '].[' + D.[Table] + ']'', ''' + D.[Column] + ''') IS NOT NULL BEGIN ALTER TABLE [' + D.[Schema] + '].[' + D.[Table] + '] DROP COLUMN [' + D.[Column] + '] END'
                            -- колонка та же самая, но что-то поменялось
                            ELSE
                                'ALTER TABLE [' + S.[Schema] + '].[' + S.[Table] + '] ALTER COLUMN [' + S.[Column] + '] ' + S.[Type] + IsNull(' Collate ' + S.[Collation], '') + CASE WHEN S.[IsNull] = 1 THEN ' NULL' ELSE ' NOT NULL' END
                        END
FROM @SrcColumns S
FULL JOIN @DstColumns D ON S.[Schema] = D.[Schema] AND S.[Table] = D.[Table] AND S.[Column] = D.[Column]
WHERE S.[Column] IS NULL
    OR D.[Column] IS NULL
    --OR S.[ColumnIndex] != D.[ColumnIndex]
    OR S.[Type] != D.[Type]
    OR S.[IsNull] != D.[IsNull]
    OR IsNull(S.[Computed:Formula], '') != IsNull(D.[Computed:Formula], '')
    OR IsNull(S.[Computed:Persisted], 0) != IsNull(D.[Computed:Persisted], 0)
    OR (IsNull(S.[Collation], '') != IsNull(D.[Collation], ''))
ORDER BY IsNull(S.[Schema], D.[Schema]), IsNull(S.[Table], D.[Table]), IsNull(S.[Column], D.[Column]);
--*/

-- представления

UPDATE @SrcViews
SET [Definition] = RTrim(LTrim(Replace(Replace(Replace([Definition], Char(9), ' '), Char(10), ' '), Char(13), ' ')));

UPDATE @DstViews
SET [Definition] = RTrim(LTrim(Replace(Replace(Replace([Definition], Char(9), ' '), Char(10), ' '), Char(13), ' ')));

--/*
IF EXISTS(SELECT * FROM @SrcViews S FULL JOIN @DstViews D ON S.[Schema] = D.[Schema] AND S.[Name] = D.[Name] WHERE S.[Name] IS NULL OR D.[Name] IS NULL OR S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Definition] != D.[Definition])
SELECT
    [View]  = '[' + IsNull(S.[Schema], D.[Schema]) + '].[' + IsNull(S.[Name], D.[Name]) + ']',
    [SQL]   =   CASE
                    -- новое представление
                    WHEN D.[Name] IS NULL THEN S.[Definition]
                    WHEN S.[Name] IS NULL THEN 'IF Object_Id(''[' + D.[Schema] + '].[' + D.[Name] + ']'', ''V'') IS NOT NULL DROP VIEW [' + D.[Schema] + '].[' + D.[Name] + ']'
                    ELSE Replace(S.[Definition], 'CREATE VIEW', 'ALTER VIEW')
                END
FROM @SrcViews S
FULL JOIN @DstViews D ON S.[Schema] = D.[Schema] AND S.[Name] = D.[Name]
WHERE S.[Name] IS NULL OR D.[Name] IS NULL OR S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Definition] != D.[Definition]
ORDER BY IsNull(S.[Schema], D.[Schema]), IsNull(S.[Name], D.[Name]);
--*/

-- функции/хранимки и т.д.
UPDATE @SrcRouties
SET [Definition] = RTrim(LTrim(Replace(Replace(Replace([Definition], Char(9), ' '), Char(10), ' '), Char(13), ' ')));

UPDATE @DstRouties
SET [Definition] = RTrim(LTrim(Replace(Replace(Replace([Definition], Char(9), ' '), Char(10), ' '), Char(13), ' ')));

--/*
IF EXISTS(SELECT * FROM @SrcRouties S FULL JOIN @DstRouties D ON S.[Schema] = D.[Schema] AND S.[Name] = D.[Name] AND D.[Type] = S.[Type] WHERE S.[Name] IS NULL OR D.[Name] IS NULL OR S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Definition] != D.[Definition])
SELECT
    [Routine]   = '[' + IsNull(S.[Schema], D.[Schema]) + '].[' + IsNull(S.[Name], D.[Name]) + ']',
    [Type]      = IsNull(S.[Type], D.[Type]),
    [ACTION]    =   CASE 
                        WHEN D.[Name] IS NULL THEN 3
                        WHEN S.[Name] IS NULL THEN 1
                        ELSE 2
                    END,
    [SQL]       =   CASE
						--ToDo сделать чтобы созадвались заглушечные объекты, а потом ALTER
                        WHEN D.[Name] IS NULL THEN 'IF OBJECT_ID(''[' + S.[Schema] + '].[' + S.[Name] + ']'', ''' + S.[Type] + ''') IS NULL EXEC(''CREATE ' + T.[TypeFull] + ' [' + S.[Schema] + '].[' + S.[Name] + '] ' + CASE WHEN S.[Type] = 'TR' THEN ' ON [].[]' ELSE '' END + 'AS SELECT 1'')'
                        WHEN S.[Name] IS NULL THEN 'IF OBJECT_ID(''[' + D.[Schema] + '].[' + D.[Name] + ']'', ''' + D.[Type] + ''') IS NOT NULL DROP ' + T.[TypeFull] + ' [' + D.[Schema] + '].[' + D.[Name] + ']'
                        ELSE Replace(S.[Definition], 'CREATE ' + T.[TypeFull], 'ALTER ' + T.[TypeFull])
                    END
FROM @SrcRouties        S
FULL JOIN @DstRouties   D ON S.[Schema] = D.[Schema] AND S.[Name] = D.[Name] AND D.[Type] = S.[Type]
CROSS APPLY
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
    ) V([Type], [TypeFull])
    WHERE V.[Type] = IsNull(S.[Type], D.[Type])
) T
WHERE S.[Name] IS NULL OR D.[Name] IS NULL OR S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Definition] != D.[Definition]
ORDER BY [ACTION], IsNull(S.[Type], D.[Type]), IsNull(S.[Schema], D.[Schema]), IsNull(S.[Name], D.[Name]);
--*/

IF EXISTS(SELECT * FROM @SrcRoles S FULL JOIN @DstRoles D ON S.[Name] = D.[Name] WHERE S.[Name] IS NULL OR D.[Name] IS NULL)
SELECT
    [RoleName]  = IsNull(S.[Name], D.[Name]),
    [SQL]       =   CASE
                        WHEN S.[Name] IS NULL THEN 'IF EXISTS(SELECT * FROM sys.database_principals WHERE type=''R'' AND name=''' + D.[name] + ''') BEGIN ' + IsNull(D.[Members], '') + ' DROP ROLE [' + D.[Name] + ']; END;'
                        WHEN D.[Name] IS NULL THEN 'IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE type=''R'' AND name=''' + S.[name] + ''') BEGIN CREATE ROLE [' + S.[Name] + ']; ' + IsNull(S.[Members], '') + ' END;'
                    END
FROM @SrcRoles S
FULL JOIN @DstRoles D ON S.[Name] = D.[Name]
WHERE S.[Name] IS NULL OR D.[Name] IS NULL
ORDER BY IsNull(S.[Name], D.[Name]);


DELETE I
FROM @SrcIndexes I
WHERE NOT EXISTS
    (
        SELECT *
        FROM @DstTables T
        WHERE T.[Schema] = I.[Schema]
            AND T.[Table] = I.[Table]
    )
    AND NOT EXISTS
    (
        SELECT *
        FROM @DstViews V
        WHERE V.[Schema] = I.[Schema]
            AND V.[Name] = I.[Table]
    );

DELETE I
FROM @DstIndexes I
WHERE NOT EXISTS
    (
        SELECT *
        FROM @SrcTables T
        WHERE T.[Schema] = I.[Schema]
            AND T.[Table] = I.[Table]
    )
    AND NOT EXISTS
    (
        SELECT *
        FROM @SrcViews V
        WHERE V.[Schema] = I.[Schema]
            AND V.[Name] = I.[Table]
    );

IF EXISTS (SELECT * FROM @SrcIndexes        S
FULL JOIN @DstIndexes   D ON    S.[Schema] = D.[Schema]
                            AND S.[Table] = D.[Table]
                            --AND D.[Name] = S.[Name]
                            AND D.[Columns] = S.[Columns]
                            AND IsNull(D.[Included], '') = IsNull(S.[Included], '')
                            AND D.[IsClustered] = S.[IsClustered]
                            AND D.[IsPrimaryKey] = S.[IsPrimaryKey]
                            AND D.[IsUnique] = S.[IsUnique]
                            AND D.[IsUniqueConstraint] = S.[IsUniqueConstraint])
SELECT
    [Object]    = '[' + IsNull(S.[Schema], D.[Schema]) + '].[' + IsNull(S.[Table], D.[Table]) + ']',
    [Index]     = IsNull(S.[Name], D.[Name]),
    [ACTION]    = CASE
					WHEN S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Name] != D.[Name] THEN 'R'
					WHEN S.[Name] IS NULL THEN 'D' 
					WHEN D.[Name] IS NULL THEN 'C' 
					ELSE '?' 
				  END,
    [SQL]       = CASE
					WHEN S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Name] != D.[Name] THEN 'IF EXISTS(SELECT * FROM sys.indexes WHERE name = ''' + D.[Name] + ''' AND object_id = Object_id(''[' + D.[Schema] + '].[' + D.[Table] + ']'')) EXEC sp_rename ''' + /*CASE WHEN D.[IsPrimaryKey] = 1 OR D.[IsUniqueConstraint] = 1 THEN '' + D.[Name] + '' ELSE */'[' + D.[Schema] + '].[' + D.[Table] + '].[' + D.[Name] + ']' /*END */+ ''', ''' + S.[Name] + '''' + CASE WHEN D.[IsPrimaryKey] = 1 OR D.[IsUniqueConstraint] = 1 THEN '' ELSE ', ''INDEX''' END + ';'
                    WHEN S.[Name] IS NULL THEN
                        -- DROP INDEX / CONSTRAINT
                        CASE
                            WHEN D.[IsPrimaryKey] = 1 OR D.[IsUniqueConstraint] = 1 THEN 'IF EXISTS(SELECT * FROM sys.indexes WHERE name = ''' + D.[Name] + ''' AND object_id = Object_id(''[' + D.[Schema] + '].[' + D.[Table] + ']'')) ALTER TABLE [' + D.[Schema] + '].[' + D.[Table] + '] DROP CONSTRAINT [' + D.[Name] + '];'
                            ELSE 'IF EXISTS(SELECT * FROM sys.indexes WHERE name = ''' + D.[Name] + ''' AND object_id = Object_id(''[' + D.[Schema] + '].[' + D.[Table] + ']'')) DROP INDEX [' + D.[Name] + '] ON [' + D.[Schema] + '].[' + D.[Table] + '];'
                        END
                        ELSE
                        CASE
                            WHEN S.[IsPrimaryKey] = 1 OR S.[IsUniqueConstraint] = 1 THEN
                                'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = ''' + S.[Name] + ''' AND object_id = Object_id(''[' + S.[Schema] + '].[' + S.[Table] + ']'')) ALTER TABLE [' + S.[Schema] + '].[' + S.[Table] + '] ADD CONSTRAINT [' + S.[Name] + '] ' +
                                CASE
                                    WHEN S.[IsPrimaryKey] = 1 THEN 'PRIMARY KEY'
                                    WHEN S.[IsUniqueConstraint] = 1 THEN 'UNIQUE'
                                    ELSE ''
                                END +
                                CASE WHEN S.[IsClustered] = 1 THEN ' CLUSTERED' ELSE ' NONCLUSTERED' END +
                                ' (' + S.[Columns] + ');'

                            ELSE 'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = ''' + S.[Name] + ''' AND object_id = Object_id(''[' + S.[Schema] + '].[' + S.[Table] + ']'')) CREATE' +
                                CASE WHEN S.[IsUnique] = 1 THEN ' UNIQUE' ELSE '' END +
                                CASE WHEN S.[IsClustered] = 1 THEN ' CLUSTERED' ELSE ' NONCLUSTERED' END + 
                                ' INDEX [' + S.[Name] + '] ON [' + S.[Schema] + '].[' + S.[Table] + '] (' + S.[Columns] + ')' +
                                CASE WHEN S.[Included] IS NOT NULL THEN ' INCLUDE (' + S.[Included] + ')' ELSE '' END + ';'
                        END
                    END
                    
FROM @SrcIndexes        S
FULL JOIN @DstIndexes   D ON    S.[Schema] = D.[Schema]
                            AND S.[Table] = D.[Table]
                            -- имя может не совпадать, тогда просто переименовываем индекс
                            --AND D.[Name] = S.[Name]
                            AND D.[Columns] = S.[Columns]
                            AND IsNull(D.[Included], '') = IsNull(S.[Included], '')
                            AND D.[IsClustered] = S.[IsClustered]
                            AND D.[IsPrimaryKey] = S.[IsPrimaryKey]
                            AND D.[IsUnique] = S.[IsUnique]
                            AND D.[IsUniqueConstraint] = S.[IsUniqueConstraint]
WHERE CASE
					WHEN S.[Name] IS NOT NULL AND D.[Name] IS NOT NULL AND S.[Name] != D.[Name] THEN 'R'
					WHEN S.[Name] IS NULL THEN 'D' 
					WHEN D.[Name] IS NULL THEN 'C' 
					ELSE '?' 
				  END != '?'
ORDER BY
    [Object],
    -- сначала дропать индексы, потом создавать
    [ACTION] DESC,
    IsNull(D.[IsPrimaryKey], S.[IsPrimaryKey]) DESC,
    IsNull(D.[IsClustered], S.[IsClustered]) DESC