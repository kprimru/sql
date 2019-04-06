USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [Common].[IntTableFromList]
(
	@List		VARCHAR(MAX),
	@Delimiter	VARCHAR(10) = ','
)
RETURNS @tbl TABLE 
(
	ITEM INT NOT NULL
) AS
BEGIN
	IF ISNULL(@List, '') = ''
		RETURN
	DECLARE
		@idxb INT, @idxe INT, 
		@item VARCHAR(8000),
		@lend INT, @lenl INT, @i INT
		
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