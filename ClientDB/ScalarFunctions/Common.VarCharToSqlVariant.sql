USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[VarCharToSqlVariant]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[VarCharToSqlVariant] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [Common].[VarCharToSqlVariant]
(
	@Value			VarChar(256),
	@DataType		VarChar(128)
)
RETURNS Sql_Variant
AS
BEGIN
	-- пока все очень тупо
	RETURN
		CASE
			WHEN Lower(@DataType) = 'bit' THEN Cast(@Value AS Bit)
			WHEN Lower(@DataType) = 'int' THEN Cast(@Value AS Int)
			WHEN Lower(@DataType) = 'smallint' THEN Cast(@Value AS SmallInt)
			WHEN Lower(@DataType) LIKE 'varchar%' THEN Cast(@Value AS VarChar(256))
			ELSE NULL
		END
END
GO
