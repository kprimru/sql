USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CheckINN]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[CheckINN] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[CheckINN]
(
	@inn varchar(15)
)
RETURNS INT
AS
BEGIN
	DECLARE @R INT
	DECLARE @I INT
	DECLARE @Num INT
	DECLARE @StrNum VARCHAR(15)
	DECLARE @CheckSumm INT
	DECLARE @L INT

	SET @R = 1
	SET @StrNum = @inn
	SET @L =  LEN (@inn)

	/* Проверка длины ИНН*/

	IF @inn = '' OR @inn = '-'
	BEGIN
		SET @R = 2
		RETURN @R
	END

	if (@L = 11) or (@L < 10) or (@L > 12)
	BEGIN
		Set @R = 0
		RETURN @R
	END

	/* ИНН 10 знаков */
	if @L = 10
	BEGIN
		SET @I = 1
		SET @CheckSumm = 0
		WHILE @I < 10
		BEGIN
			SET @Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1))
			SET @StrNum = SUBSTRING (@StrNum, 2, @L)
			IF @I = 1
				SET @CheckSumm = @CheckSumm + @Num * 2 
			IF @I = 2
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 3
				SET @CheckSumm = @CheckSumm + @Num * 10 
			IF @I = 4
				SET @CheckSumm = @CheckSumm + @Num * 3 
			IF @I = 5
				SET @CheckSumm = @CheckSumm + @Num * 5 
			IF @I = 6
				SET @CheckSumm = @CheckSumm + @Num * 9 
			IF @I = 7
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 8
				SET @CheckSumm = @CheckSumm + @Num * 6 
			IF @I = 9
				SET @CheckSumm = @CheckSumm + @Num * 8 

			SET @I = @I + 1
		END

		SET @Num = @CheckSumm % 11
		IF @Num = 10
			SET @Num = 0
		IF NOT(@Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1)))
		BEGIN
			SET @R = 0
			RETURN @R
		END
	END

	/* ИНН 12 знаков */
	if @L = 12
	BEGIN
		SET @I = 1
		SET @CheckSumm = 0
		WHILE @I < 11
		BEGIN
			SET @Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1))
			SET @StrNum = SUBSTRING (@StrNum, 2, @L)

			IF @I = 1
				SET @CheckSumm = @CheckSumm + @Num * 7 
			IF @I = 2
				SET @CheckSumm = @CheckSumm + @Num * 2 
			IF @I = 3
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 4
				SET @CheckSumm = @CheckSumm + @Num * 10 
			IF @I = 5
				SET @CheckSumm = @CheckSumm + @Num * 3
			IF @I = 6
				SET @CheckSumm = @CheckSumm + @Num * 5 
			IF @I = 7
				SET @CheckSumm = @CheckSumm + @Num * 9 
			IF @I = 8
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 9
				SET @CheckSumm = @CheckSumm + @Num * 6 
			IF @I = 10
				SET @CheckSumm = @CheckSumm + @Num * 8
			SET @I = @I + 1
		END

		SET @Num = @CheckSumm % 11

		IF @Num = 10
			SET @Num = 0
		IF NOT(@Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1)))
		BEGIN
			SET @R = 0
			RETURN @R
		END

		SET @StrNum = @inn
		SET @I = 1
		SET @CheckSumm = 0
		WHILE @I < 12
		BEGIN
			SET @Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1))
			SET @StrNum = SUBSTRING (@StrNum, 2, @L)
			IF @I = 1
				SET @CheckSumm = @CheckSumm + @Num * 3 
			IF @I = 2
				SET @CheckSumm = @CheckSumm + @Num * 7 
			IF @I = 3
				SET @CheckSumm = @CheckSumm + @Num * 2 
			IF @I = 4
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 5
				SET @CheckSumm = @CheckSumm + @Num * 10
			IF @I = 6
				SET @CheckSumm = @CheckSumm + @Num * 3 
			IF @I = 7
				SET @CheckSumm = @CheckSumm + @Num * 5
			IF @I = 8
				SET @CheckSumm = @CheckSumm + @Num * 9 
			IF @I = 9
				SET @CheckSumm = @CheckSumm + @Num * 4 
			IF @I = 10
				SET @CheckSumm = @CheckSumm + @Num * 6
			IF @I = 11
				SET @CheckSumm = @CheckSumm + @Num * 8
			SET @I = @I + 1
		END

		SET @Num = @CheckSumm % 11

		IF @Num = 10
			SET @Num = 0
		IF NOT(@Num = CONVERT(INT, SUBSTRING (@StrNum, 1, 1)))
		BEGIN
			SET @R = 0
			RETURN @R
		END
	END

	RETURN @R
END
GO
