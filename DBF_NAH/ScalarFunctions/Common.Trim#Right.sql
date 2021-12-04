USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[Trim#Right]
(
    @Str    VarChar(Max),
    @Sym    Char(1)
)
RETURNS VarChar(Max)
AS
BEGIN
	WHILE SubString(@Str, Len(@Str), 1) = @Sym
	    SET @Str = Left(@Str, Len(@Str) - 1);

	RETURN @Str
END
GO
