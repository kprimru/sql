USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DistrString]
(
	@SysShort	VarChar(20),
	@Distr		Int,
	@Comp		TinyInt
)
RETURNS VARCHAR(50)
WITH SCHEMABINDING
AS
BEGIN
	RETURN IsNull(@SysShort + ' ', '') + CAST(@Distr AS VarChar(10)) + CASE @Comp WHEN 1 THEN '' ELSE '/' + CAST(@Comp AS VarChar(10)) END
END
