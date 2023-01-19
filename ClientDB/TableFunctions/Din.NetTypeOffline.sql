USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[NetTypeOffline]', 'TF') IS NULL EXEC('CREATE FUNCTION [Din].[NetTypeOffline] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [Din].[NetTypeOffline]()
RETURNS @Result TABLE
(
	NT_ID SmallInt
)
AS
BEGIN
	DECLARE @Tmp Table
	(
		NT_ID Sql_Variant
	);

	INSERT INTO @Tmp
	SELECT SetItem
	FROM dbo.NamedSetItemsSelect('Din.NetType', 'Оффлайн')

	INSERT INTO @Result
	SELECT Cast(NT_ID AS SmallInt)
	FROM @Tmp

	RETURN
END
GO
