/****** Object:  StoredProcedure [SQL].[ObjectText]    Script Date: 11.09.2022 0:54:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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