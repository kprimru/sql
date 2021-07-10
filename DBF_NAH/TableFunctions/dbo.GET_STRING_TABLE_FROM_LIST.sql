USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[GET_STRING_TABLE_FROM_LIST](@List VARCHAR(MAX), @Delimiter VARCHAR(10)=',')
RETURNS @tbl TABLE (Item VARCHAR(100) NOT NULL) AS
BEGIN
  DECLARE
    @idxb int, @idxe int,
    @item varchar(MAX),
    @lend int, @lenl int, @i int
  SET @lend = DATALENGTH(@Delimiter)
  SET @lenl = DATALENGTH(@List)
  SET @idxb = 1
  WHILE SUBSTRING(@List, @idxb, @lend) = @Delimiter AND @idxb < @lenl - @lend + 1
    SET @idxb = @idxb + @lend

  SET @idxe = @idxb
  WHILE @idxb <= @lenl AND @idxe <= @lenl
  BEGIN
    IF SUBSTRING(@List, @idxe + 1, @lend) = @Delimiter
    BEGIN
      SET @item = SUBSTRING(@List, @idxb, @idxe - @idxb + 1)
      INSERT INTO @tbl (Item) VALUES (@item)
      SET @idxb = @idxe + @lend + 1
      WHILE SUBSTRING(@List, @idxb, @lend) = @Delimiter AND @idxb < @lenl - @lend + 1
        SET @idxb = @idxb + @lend
      SET @idxe = @idxb
    END
    ELSE IF @idxe = @lenl
    BEGIN
      SET @item = SUBSTRING(@List, @idxb, @idxe - @idxb + 1)
      IF @item <> @Delimiter
        INSERT INTO @tbl (Item) VALUES (@item)
      RETURN
    END
    ELSE
    BEGIN
      SET @idxe = @idxe + 1
    END
  END
  RETURN
END


GO
