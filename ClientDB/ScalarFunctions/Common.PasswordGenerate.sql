﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[PasswordGenerate]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[PasswordGenerate] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Common].[PasswordGenerate]
(
	-- кол-во симоволов
	@LN	SMALLINT
)
RETURNS NVARCHAR(128)
AS
BEGIN
	DECLARE @RES NVARCHAR(128)

	DECLARE @KEY INT
	SET @RES = ''

	WHILE LEN(@RES) < @LN
	BEGIN
		SET @KEY = CAST(Common.Rand_f()*255 AS INT)%127
		IF PATINDEX('%[a-zA-Z0-9]%',CHAR(@KEY)) > 0 
		SET @RES = @RES + CHAR(@KEY)
	END

	RETURN @RES
END
GO
