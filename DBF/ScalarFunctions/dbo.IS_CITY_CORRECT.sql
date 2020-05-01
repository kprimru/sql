USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Возвращает 0, если название 
--                населенного пункта корректно 
--                (присутствует в справочнике). 
--                При этом префикс не учитывается
-- =============================================
ALTER FUNCTION [dbo].[IS_CITY_CORRECT]
(
	@citystr varchar(100)
)
RETURNS int
AS
BEGIN
	
	DECLARE @prefix varchar(50)
    DECLARE @name varchar(100)

    SET @prefix = ''
    SET @name = ''

    SET @citystr = LTRIM(RTRIM(@citystr))

	IF CHARINDEX('.', @citystr) <> 0 
      BEGIN
        -- есть точка, значит скорее всего есть г. До точки включительно - префикс
        SET @prefix = LEFT(@citystr, CHARINDEX('.', @citystr))
        SET @citystr = RIGHT(@citystr, LEN(@citystr) - CHARINDEX('.', @citystr))        
       
        SET @citystr = LTRIM(RTRIM(@citystr))
        SET @name = @citystr
      END
    ELSE
      BEGIN
        SET @name = @citystr
        SET @prefix = '' 
      END
	
    IF EXISTS(SELECT * FROM CityTable WHERE CT_NAME = @name)
      RETURN 0
    ELSE
      RETURN 1

    RETURN 1

END


