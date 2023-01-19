USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[Trim#Right]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[Trim#Right] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[Trim#Right]
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
