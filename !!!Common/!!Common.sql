/*
1. Схемы System, SQL, Debug
2. Таблицы System.SessionVariables, Debug.ExecutionStart/Point/Finish (при асинхронном запуске вынести Debug в отдельную БД)
3. Процедуры и функици SessionVariable@Set, Debug*, SQL*

Как это накатывать на все БД? Сделать отдельный патч?
*/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'System')
	EXEC('CREATE SCHEMA [System];');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SQL')
	EXEC('CREATE SCHEMA [SQL];');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Debug')
	EXEC('CREATE SCHEMA [Debug];');
GO
IF Object_Id('[Debug].[Executions:Finish]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Finish]
	(
		[Id]				BigInt			NOT NULL,
		[FinishDateTime]	DateTime		NOT NULL,
		[Error]				VarChar(512)		NULL,
	    CONSTRAINT [PK_Debug.Executions:Finish] PRIMARY KEY CLUSTERED  ([Id])
	);
END

IF Object_Id('[Debug].[Executions:Point]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Point]
	(
		[Id]			BigInt		IDENTITY(1,1)	NOT NULL,
		[Execution_Id]	BigInt						NOT NULL,
		[Row:Index]		TinyInt						NOT NULL,
		[StartDateTime] DateTime					NOT NULL,
		[Name]			VarChar(128)				NOT NULL,
		CONSTRAINT [PK_Debug.Executions:Point] PRIMARY KEY CLUSTERED 
		(
			[Execution_Id] ASC,
			[Row:Index] ASC
		)
	);
END;

IF Object_Id('[Debug].[Executions:Point:Params]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Point:Params]
	(
		[Id]		BigInt			NOT NULL,
		[Row:Index] TinyInt			NOT NULL,
		[Name]		VarChar(100)	NOT NULL,
		[Value]		VarChar(Max)	NOT NULL,
		CONSTRAINT [PK_Debug.Executions:Point:Params] PRIMARY KEY CLUSTERED 
		(
			[Id] ASC,
			[Row:Index] ASC
		)
	);
END;

IF Object_Id('[Debug].[Executions:Start]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Start]
	(
		[Id]			BigInt		IDENTITY(1,1)	NOT NULL,
		[StartDateTime] DateTime					NOT NULL,
		[Object]		VarChar(512)				NOT NULL,
		[UserName]		VarChar(128)				NOT NULL,
		[HostName]		VarChar(128)				NOT NULL,
		CONSTRAINT [PK_Debug.Executions:Start] PRIMARY KEY CLUSTERED 
		(
			[Id] ASC
		)
	);
END;
GO

IF Object_Id('[Debug].[Executions:Start:Params]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Start:Params]
	(
		[Id]		BigInt			NOT NULL,
		[Row:Index] TinyInt			NOT NULL,
		[Name]		VarChar(100)	NOT NULL,
		[Value]		VarChar(Max)	NOT NULL,
		CONSTRAINT [PK_Debug.Executions:Start:Params] PRIMARY KEY CLUSTERED 
		(
			[Id] ASC,
			[Row:Index] ASC
		)
	);
END;
GO


IF Object_Id('[Debug].[Executions:Start:Params]', 'U') IS NULL BEGIN
	CREATE TABLE [Debug].[Executions:Start:Params]
	(
		[Id]		BigInt			NOT NULL,
		[Row:Index] TinyInt			NOT NULL,
		[Name]		VarChar(100)	NOT NULL,
		[Value]		VarChar(Max)	NOT NULL,
		CONSTRAINT [PK_Debug.Executions:Start:Params] PRIMARY KEY CLUSTERED 
		(
			[Id] ASC,
			[Row:Index] ASC
		)
	);
END;
GO
CREATE OR ALTER FUNCTION [Debug].[Execution@Enabled]()
RETURNS Bit
AS
BEGIN
	RETURN 0;
END
GO
CREATE OR ALTER FUNCTION [Debug].[Execution:Params@Parse]
(
	@Params Xml
)
RETURNS TABLE
AS
RETURN 
(
	SELECT
		[Row:Index] = 1,
		[Name]		= 'Name',
		[Value]		= 'Value'
	WHERE @Params IS NULL
	
	UNION ALL
	
	SELECT
        Row_Number() OVER(ORDER BY (SELECT 1)),
        v.value('@Name[1]', 'VarChar(256)'),
        v.value('@Value[1]', 'VarChar(Max)')
    FROM @Params.nodes('/PARAMS/PARAM') AS n(v)
)
GO
CREATE OR ALTER PROCEDURE [Debug].[Execution@Finish]
	@DebugContext	Xml,
	@Error			VarChar(512)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    IF [Debug].[Execution@Enabled]() = 0
        RETURN;

    DECLARE
        @Id             BigInt,
        @FinishDateTime DateTime;

    SET @Id             = @DebugContext.value('(/DEBUG/@Id)[1]', 'BigInt');
    SET @FinishDateTime = GetDate();

    IF @Id IS NOT NULL
        INSERT INTO [Debug].[Executions:Finish]([Id], [FinishDateTime], [Error])
        VALUES(@Id, @FinishDateTime, @Error);
END;
GO
CREATE OR ALTER PROCEDURE [Debug].[Execution@Point]
    @DebugContext   Xml,
    @Name           VarChar(128),
    @Params         Xml             = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    IF [Debug].[Execution@Enabled]() = 0
        RETURN;

    DECLARE
        @Id             BigInt,
        @FinishDateTime DateTime;

    SET @Id         = @DebugContext.value('(/DEBUG/@Id)[1]', 'BigInt');

    INSERT INTO [Debug].[Executions:Point]([Execution_Id], [Row:Index], [StartDateTime], [Name])
    SELECT @Id, IsNull([Row:Index] + 1, 1), GetDate(), @Name
    FROM (SELECT [Null] = NULL) AS N
    OUTER APPLY
    (
        SELECT TOP (1)
            P.[Row:Index]
        FROM [Debug].[Executions:Point] AS P
        WHERE P.[Execution_Id] = @Id
        ORDER BY
            P.[Row:Index] DESC
    ) AS P;

    SELECT @Id = Scope_Identity();
    
    IF @Params IS NOT NULL BEGIN
        INSERT INTO [Debug].[Executions:Point:Params]([Id], [Row:Index], [Name], [Value])
        SELECT @Id, P.[Row:Index], P.[Name], P.[Value]
        FROM [Debug].[Execution:Params@Parse](@Params) P;
    END;
END;
GO
CREATE OR ALTER PROCEDURE [Debug].[Execution@Start]
	@Proc_Id		Int,
	@Params			Xml,
	@DebugContext	Xml OUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    IF [Debug].[Execution@Enabled]() = 0
        RETURN;

    DECLARE
        @Id             BigInt,
        @StartDateTime  DateTime,
        @Object         VarChar(512),
        @UserName       VarChar(128),
        @HostName       VarChar(128);

    SET @StartDateTime  = GetDate();
    SET @Object         = '[' + Object_Schema_Name(@Proc_Id) + '].[' + Object_Name(@Proc_Id) + ']';
    SET @UserName       = Original_Login();
    SET @HostName       = Host_Name();

    INSERT INTO [Debug].[Executions:Start]([StartDateTime], [Object], [UserName], [HostName])
    VALUES(@StartDateTime, @Object, @UserName, @HostName);

    SELECT @Id = Scope_Identity();

    SET @DebugContext = 
        (
            SELECT
                [Id]            = @Id,
                [StartDateTime] = @StartDateTime
            FOR XML RAW('DEBUG'), TYPE
        );

    IF @Params IS NOT NULL BEGIN
        INSERT INTO [Debug].[Executions:Start:Params]([Id], [Row:Index], [Name], [Value])
        SELECT @Id, P.[Row:Index], P.[Name], P.[Value]
        FROM [Debug].[Execution:Params@Parse](@Params) P;
    END;
END;
GO
CREATE OR ALTER PROCEDURE [Debug].[Executions@Clear]
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
CREATE OR ALTER PROCEDURE [Debug].[Executions@Read]
    @MaxResultCount Int             = 20,
    @Object         NVarChar(512)   = NULL,
    @Exec_Id        BigInt          = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE
		@ErrorMessage	NVarChar(2048),
		@ErrorSeverity	Int,
		@ErrorState		Int;

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
    SET @ObjectDefinition = Replace(@ObjectDefinition, 'CREATE OR ALTER FUNCTION',   'ALTER FUNCTION');
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
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition?Permissions]
(
    @Object_Id      Int
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE
        @ObjectName     NVarChar(256),
        @Result         NVarChar(Max);

    SET @Result = N'';
    SET @ObjectName = '[' + Object_Schema_Name(@Object_Id) + '].[' + Object_Name(@Object_Id) + ']';

    SELECT @Result = @Result + state_desc + ' ' + permission_name + ' ON ' + @ObjectName + ' TO ' + r.name + ';' + Char(10)
    FROM sys.database_permissions p
    INNER JOIN sys.database_principals r ON p.grantee_principal_id = r.principal_Id
    WHERE p.[major_id] = @Object_Id
    ORDER BY r.name;

    IF @Result != ''
        SET @Result = Left(@Result, Len(@Result) - 1)
    ELSE
        SET @Result = NULL;

    RETURN @Result;
END;
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
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition?View]
(
    @Object_Id      Int
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE @Result NVarChar(Max);

    SET @Result = Object_Definition(@Object_Id);

    SET @Result = @Result + IsNull('
GO
' + [SQL].[ObjectDefinition?Indexes](@Object_Id) + '
', '');

    RETURN @Result;
END;
GO
DROP FUNCTION IF EXISTS [SQL].[Split];
GO
CREATE OR ALTER FUNCTION [SQL].[Split]
(
    @String     VarChar(Max),
    @Delimiter  Char(1)
)
RETURNS TABLE
AS RETURN
(
	SELECT S.value AS [Item]
	FROM string_split(@String, @Delimiter) AS S
)
GO
CREATE OR ALTER PROCEDURE [SQL].[ObjectText]
    @ObjectName VarChar(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE
        @Line           NVarChar(Max),
        @NextLine       NVarChar(Max),
        @ObjectText     NVarChar(Max);

    SELECT @ObjectText = Object_Definition(Object_Id)
    FROM sys.objects
    WHERE Object_Id = Object_Id(@ObjectName)
    
    SET @ObjectText = Replace(@ObjectText, 'ALTER PROCEDURE', 'ALTER PROCEDURE')

    SET @ObjectText = Replace(@ObjectText, 'CREATE FUNCTION', 'ALTER FUNCTION')

    SET @ObjectText = Replace(@ObjectText, 'CREATE VIEW', 'ALTER VIEW')

    SET @ObjectText = Replace(@ObjectText, 'CREATE TRIGGER', 'ALTER TRIGGER')

    IF @ObjectText LIKE '%END'
        SET @ObjectText = @ObjectText + Char(10)

    WHILE CharIndex(' ' + Char(13), @ObjectText) != 0
        SET @ObjectText = Replace(@ObjectText, ' ' + Char(13), Char(13));

    WHILE CharIndex('	' + Char(13), @ObjectText) != 0
        SET @ObjectText = Replace(@ObjectText, '	' + Char(13), Char(13));

    PRINT ('USE [' + DB_NAME() + ']' + '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO')

    WHILE (1 = 1) BEGIN

        IF @ObjectText IS NULL
            BREAK;

        IF CharIndex(Char(13) + Char(10), @ObjectText) = 0
            BREAK;

        SET @Line = Left(@ObjectText, CharIndex(Char(13) + Char(10), @ObjectText) - 1);

        SET @Line = Replace(Replace(@Line, Char(10), ''), Char(13), '');
        SET @Line = RTrim(@Line);
        
        SET @ObjectText = Right(@ObjectText, Len(@ObjectText) - CharIndex(Char(13) + Char(10), @ObjectText) - 1)
        
        IF CharIndex(Char(13) + Char(10), @ObjectText) > 0
            SET @NextLine = Left(@ObjectText, CharIndex(Char(13) + Char(10), @ObjectText) - 1);

        SET @NextLine = Replace(Replace(@NextLine, Char(10), ''), Char(13), '');
        SET @NextLine = RTrim(@NextLine);
        
        IF @NextLine = ''
            SET @Line = @Line + Char(10);
            
        IF @Line != ''
            PRINT (@Line);
    END;
    
    SET @Line = 'GO
' +
    IsNull(
        (
            SELECT state_desc + ' ' + permission_name + ' ON ' + @ObjectName + ' TO ' + r.name + ';' + Char(10)
            FROM sys.database_permissions p
            INNER JOIN sys.database_principals r ON p.grantee_principal_id = r.principal_Id
            WHERE p.major_id = object_id(@ObjectName)
            ORDER BY r.name FOR XML PATH('')
        ) + 'GO', '');
    
    PRINT(@Line);
END;
GO
CREATE OR ALTER PROCEDURE [SQL].[Search]
    @String VarChar(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        [Object_Name]   = '[' + S.[name] + '].[' + O.[name] + ']',
        [Line]          = LTrim(RTrim(Replace(Replace(L.[Line], Char(13), ''), Char(9), '')))
    FROM [sys].[objects]        AS O
    INNER JOIN [sys].[schemas]  AS S ON O.[schema_Id] = S.[schema_id]
    CROSS APPLY
    (
        SELECT [Line] = Item
        FROM [SQL].[Split](Object_Definition(Object_Id), Char(10))
    ) AS L
    WHERE Object_Definition(Object_Id) LIKE '%' + @String + '%'
        AND L.[Line] LIKE '%' + @String + '%'
    ORDER BY
        S.[name],
        O.[name]
END;
GO
