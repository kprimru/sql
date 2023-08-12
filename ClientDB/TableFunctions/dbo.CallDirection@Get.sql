USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CallDirection@Get]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[CallDirection@Get] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE OR ALTER FUNCTION [dbo].[CallDirection@Get](@NamedSetName VarChar(128))
RETURNS @Result TABLE
(
	Id UniqueIdentifier PRIMARY KEY CLUSTERED
)
AS
BEGIN
	DECLARE @Tmp Table
	(
		Id Sql_Variant
	);

	INSERT INTO @Tmp
	SELECT SetItem
	FROM dbo.NamedSetItemsSelect('dbo.CallDirection', @NamedSetName)

	INSERT INTO @Result
	SELECT Cast(Id AS UniqueIdentifier)
	FROM @Tmp

	RETURN
END
GO
