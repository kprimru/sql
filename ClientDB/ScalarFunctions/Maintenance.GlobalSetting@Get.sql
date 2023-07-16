USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalSetting@Get]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalSetting@Get] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Maintenance].[GlobalSetting@Get]
(
    @Name   VarChar(128)
)
RETURNS Sql_Variant
AS
BEGIN
    RETURN
		(
			SELECT Cast([GS_VALUE] AS Sql_Variant)
			FROM [Maintenance].[GlobalSettings]
			WHERE [GS_NAME] = @Name
		)
END
GO
