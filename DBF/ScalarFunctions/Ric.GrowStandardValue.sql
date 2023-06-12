USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[GrowStandardValue]', 'FN') IS NULL EXEC('CREATE FUNCTION [Ric].[GrowStandardValue] () RETURNS Int AS BEGIN RETURN NULL END')
GO
/*
	Показатель нормального роста
*/
CREATE FUNCTION [Ric].[GrowStandardValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	SET @RES = 3

	RETURN @RES
END
GO
