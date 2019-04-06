USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Common].[NumToStr]
(
	@NUM			BIGINT,
	@IS_MALE_GENDER	BIT
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @nword VARCHAR(255)
	DECLARE @th TINYINT 
	DECLARE @gr SMALLINT 
	DECLARE @d3 TINYINT 
	DECLARE @d2 TINYINT
	DECLARE @d1 TINYINT
	
	IF @Num < 0 
		RETURN '*** Ошибка. Отрицательное число' 
	ELSE IF @Num=0 
		RETURN 'Ноль'
		
	
	WHILE @Num > 0
	BEGIN
		SET @th = ISNULL(@th, 0) + 1
		SET @gr = @Num % 1000    
		SET @Num = (@Num - @gr) / 1000
		
		IF @gr > 0
		BEGIN
			SET @d3 = (@gr - @gr % 100) / 100
			SET @d1 = @gr % 10
			SET @d2 = (@gr - @d3 * 100 - @d1) / 10
			
			IF @d2 = 1 
				SET @d1 = 10 + @d1
				
			SET @nword = 
				CASE @d3
					WHEN 1 THEN ' сто' 
					WHEN 2 THEN ' двести' 
					WHEN 3 THEN ' триста'
					WHEN 4 THEN ' четыреста' 
					WHEN 5 THEN ' пятьсот' 
					WHEN 6 THEN ' шестьсот'
					WHEN 7 THEN ' семьсот' 
					WHEN 8 THEN ' восемьсот' 
					WHEN 9 THEN ' девятьсот' 
					ELSE '' 
				END +
				CASE @d2
					WHEN 2 THEN ' двадцать' 
					WHEN 3 THEN ' тридцать' 
					WHEN 4 THEN ' сорок'
					WHEN 5 THEN ' пятьдесят' 
					WHEN 6 THEN ' шестьдесят' 
					WHEN 7 THEN ' семьдесят'
					WHEN 8 THEN ' восемьдесят' 
					WHEN 9 THEN ' девяносто' 
					ELSE '' 
				END +
				CASE @d1
					WHEN 1 THEN
						(
							case 
								WHEN @th = 2 OR (@th = 1 AND @IS_MALE_GENDER = 0) THEN ' одна' 
								ELSE ' один' 
							END)
					WHEN 2 THEN
						(
							CASE 
								WHEN @th = 2 OR (@th = 1 AND @IS_MALE_GENDER = 0) THEN ' две' 
								ELSE ' два' 
							END
						)
					WHEN 3 THEN ' три' 
					WHEN 4 THEN ' четыре' 
					WHEN 5 THEN ' пять'
					WHEN 6 THEN ' шесть' 
					WHEN 7 THEN ' семь' 
					WHEN 8 THEN ' восемь'
					WHEN 9 THEN ' девять' 
					WHEN 10 THEN ' десять' 
					WHEN 11 THEN ' одиннадцать'
					WHEN 12 THEN ' двенадцать' 
					WHEN 13 THEN ' тринадцать' 
					WHEN 14 THEN ' четырнадцать'
					WHEN 15 THEN ' пятнадцать' 
					WHEN 16 THEN ' шестнадцать'
					WHEN 17 THEN ' семнадцать'
					WHEN 18 THEN ' восемнадцать' 
					WHEN 19 THEN ' девятнадцать'
					ELSE '' 
				END +
				CASE @th
					WHEN 2 THEN ' тысяч' + 
							(
								CASE 
									WHEN @d1 = 1 THEN 'а' 
									WHEN @d1 IN (2, 3, 4) THEN 'и' 
									ELSE ''   
								END
							)
					WHEN 3 THEN ' миллион' 
					WHEN 4 THEN ' миллиард' 
					WHEN 5 THEN ' триллион' 
					WHEN 6 THEN ' квадрилион' 
					WHEN 7 THEN ' квинтилион'
					ELSE '' 
				END +
				CASE 
					WHEN @th IN (3, 4, 5, 6, 7) THEN 
						(
							CASE
								WHEN @d1 = 1 THEN ''
								WHEN @d1 IN (2, 3, 4) THEN 'а' 
								ELSE 'ов' 
							END
						)						 
					ELSE '' 
				END + ISNULL(@nword, '')
		END
	END
  RETURN UPPER(SUBSTRING(@nword, 2, 1)) + SUBSTRING(@nword, 3, LEN(@nword) - 2)
END