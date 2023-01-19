﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MoneyMax]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[MoneyMax] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[MoneyMax]
(
	@A	MONEY,
	@B	MONEY
)
RETURNS MONEY
AS
BEGIN
	DECLARE @RES MONEY

	IF @A > @B
		SET @RES = @A
	ELSE
		SET @RES = @B

	RETURN @RES
END
GO
