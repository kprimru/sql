USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [Common].[TableFromList]
	(
		@List VARCHAR(MAX),
		@Delimiter VARCHAR(10) = ','
	)
RETURNS @tbl TABLE (ID UNIQUEIDENTIFIER NOT NULL) AS
BEGIN
	IF ISNULL(@List, '') = ''
		RETURN

	DECLARE @idxb INT
	DECLARE @idxe INT
    DECLARE @item VARCHAR(MAX)
    DECLARE @lend INT
	DECLARE @lenl INT
	DECLARE @i INT

	SET @lend = DATALENGTH(@Delimiter)
	SET @lenl = DATALENGTH(@List)
	SET @idxb = 1

	WHILE SUBSTRING(@List, @idxb, @lend) = @Delimiter
								AND @idxb < @lenl - @lend + 1
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
					WHERE ID = @item
				)
				INSERT INTO @tbl (ID) VALUES (@item)

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
						WHERE ID = @item
					)
					INSERT INTO @tbl (ID) VALUES (@item)
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
