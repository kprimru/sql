/****** Object:  UserDefinedFunction [SQL].[ObjectDefinition?Permissions]    Script Date: 11.09.2022 0:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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