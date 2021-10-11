USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[Split]
(
    @String     VarChar(Max),
    @Delimiter  Char(1)
)
RETURNS @output TABLE(Item VarChar(MAX))
BEGIN
    DECLARE
        @start  Int,
        @end    Int;

    SELECT
        @start  = 1,
        @end    = CharIndex(@delimiter, @string);

    WHILE @start < Len(@string) + 1 BEGIN
        IF @end = 0
            SET @end = LEN(@string) + 1

        INSERT INTO @output (Item)
        VALUES(SubString(@string, @start, @end - @start));

        SET @start = @end + 1;
        SET @end = CHARINDEX(@delimiter, @string, @start);
    END

    RETURN
END
GO
