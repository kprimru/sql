USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LessonPlace@Get]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[LessonPlace@Get] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [dbo].[LessonPlace@Get](@NamedSetName VarChar(128))
RETURNS @Result TABLE
(
	Id Int PRIMARY KEY CLUSTERED
)
AS
BEGIN
	DECLARE @Tmp Table
	(
		Id Sql_Variant
	);

	INSERT INTO @Tmp
	SELECT SetItem
	FROM dbo.NamedSetItemsSelect('dbo.LessonPlaceTable', @NamedSetName)

	INSERT INTO @Result
	SELECT Cast(Id AS Int)
	FROM @Tmp

	RETURN
END
GO
