USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[System].[Setting@Get]', 'FN') IS NULL EXEC('CREATE FUNCTION [System].[Setting@Get] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [System].[Setting@Get]
(
    @Name   VarChar(128)
)
RETURNS Sql_Variant
AS
BEGIN
    RETURN
		(
			SELECT [Value]
			FROM [System].[Settings]
			WHERE [Name] = @Name
		)
END
GO
