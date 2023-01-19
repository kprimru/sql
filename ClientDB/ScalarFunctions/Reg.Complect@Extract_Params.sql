USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[Complect@Extract?Params]', 'FN') IS NULL EXEC('CREATE FUNCTION [Reg].[Complect@Extract?Params] () RETURNS Int AS BEGIN RETURN NULL END')
GO
/*
SELECT
	[Reg].[Complect@Extract?Params]('RLAW020#123456_02', 'COMP'),
	[Reg].[Complect@Extract?Params]('RLAW020#123456_02', 'SYSTEM'),
	[Reg].[Complect@Extract?Params]('RLAW020#123456_02', 'DISTR'),
	[Reg].[Complect@Extract?Params]('RLAW020#123456_02', 'LOG')
*/
CREATE FUNCTION [Reg].[Complect@Extract?Params]
(
	@Complect	VarChar(100),
	-- параметр, который вернуть: SYSTEM, DISTR, COMP
	@ParamName	VarChar(20)
)
RETURNS Sql_Variant
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS
BEGIN
	DECLARE
		@Comp	TinyInt,
		@Distr	Int,
		@System	VarCHar(50);

	IF @ParamName NOT IN ('SYSTEM', 'DISTR', 'COMP')
		RETURN NULL;

	IF @ParamName = 'COMP' BEGIN
		IF (CharIndex('_', @Complect) > 0)
			RETURN Cast(Cast(Right(@Complect, Len(@Complect) - CharIndex('_', @Complect)) AS TinyInt) AS Sql_Variant)
		ELSE
			RETURN (Cast(1 AS Sql_Variant))
	END;

	IF (CharIndex('_', @Complect) > 0)
		SET @Complect = Left(@Complect, CharIndex('_', @Complect) - 1);

	IF CharIndex('#', @Complect) > 0 BEGIN
		SET @System = Left(@Complect, CharIndex('#', @Complect) - 1);
		SET @Complect = Right(@Complect, Len(@Complect) - Len(@System) - 1);
	END;
	ELSE BEGIN
		SET @System = '';
		WHILE (1 = 1) BEGIN
			IF NOT Left(@Complect, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') BEGIN
				SET @System = @System + Left(@Complect, 1);
				SET @Complect = Right(@Complect, Len(@Complect) - 1)
			END ELSE
				BREAK;
		END;
	END;

	IF @ParamName = 'SYSTEM'
		RETURN Cast(@System AS Sql_Variant);

	IF @ParamName = 'DISTR'
		RETURN Cast(Cast(@Complect AS Int) AS Sql_Variant);

	RETURN NULL;
END
GO
