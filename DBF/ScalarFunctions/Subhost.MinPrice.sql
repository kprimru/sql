USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Subhost].[MinPrice]
(
	@SH_ID	INT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @RES MONEY

	IF @SH_ID IN (12)
		SET @RES = 58
	ELSE
		SET @RES = 59


	RETURN @RES
END
