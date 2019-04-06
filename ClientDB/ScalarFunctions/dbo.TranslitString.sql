USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TranslitString]
(
	@SOURCE	VARCHAR(4000)
)
RETURNS VARCHAR(4000)
AS
BEGIN
	DECLARE @RES VARCHAR(4000)

	DECLARE @str VARCHAR(4000)
	DECLARE	@str_lat VARCHAR(8000)

	SET @str = @SOURCE

	DECLARE @rus VARCHAR(100)
	DECLARE @lat1 VARCHAR(100)
	DECLARE @lat2 VARCHAR(100)
	DECLARE	@lat3 VARCHAR(100)

	SET @rus =  'אבגדהו¸זחטיךכלםמןנסעףפץצקרשתûü‎‏ÿ'
	SET @lat1 = 'abvgdejzzijklmnoprstufkccss"y''ejj' 
	SET @lat2 = '      oh  j           h hhh   hua'
	SET @lat3 = '                          h      '

	DECLARE @i INT
	DECLARE @pos INT
	DECLARE @ch VARCHAR(2)

	SET @i = 1
	SET @str_lat = ''

	WHILE @i <= len(@str)
	BEGIN
		SET @ch = substring(@str, @i, 1)
		SET @pos = charindex(@ch, @rus)

		IF @pos > 0
		BEGIN
			IF ASCII(UPPER(@ch)) = ASCII(@ch)
				SET @str_lat = @str_lat + UPPER(SUBSTRING(@lat1, @pos, 1)) + RTRIM(SUBSTRING(@lat2, @pos, 1)) + RTRIM(SUBSTRING(@lat3, @pos, 1))
			ELSE
				SET @str_lat = @str_lat + SUBSTRING(@lat1, @pos, 1) + RTRIM(SUBSTRING(@lat2, @pos, 1)) + RTRIM(SUBSTRING(@lat3, @pos, 1))
		END
		ELSE
			SET @str_lat = @str_lat + @ch
		SET @i = @i + 1
	END

	SET @RES = @str_lat


	RETURN @RES		
END