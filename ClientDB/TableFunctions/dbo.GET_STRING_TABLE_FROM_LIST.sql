USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_STRING_TABLE_FROM_LIST]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_STRING_TABLE_FROM_LIST] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [dbo].[GET_STRING_TABLE_FROM_LIST](@List VARCHAR(MAX), @Delimiter VARCHAR(10)=',')
RETURNS @tbl TABLE (Item VARCHAR(500) NOT NULL) AS
BEGIN
  IF ISNULL(@List, '') = ''
    RETURN
  DECLARE
    @idxb int, @idxe int,
    @item varchar(8000),
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
	  IF NOT EXISTS
		(
			SELECT *
			FROM @tbl
			WHERE Item = @item
		)
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
		BEGIN
		IF NOT EXISTS
		(
			SELECT *
			FROM @tbl
			WHERE Item = @item
		)
			INSERT INTO @tbl (Item) VALUES (@item)
		END
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
