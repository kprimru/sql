USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Возвращает 0, если название улицы 
--                корректно (присутствует в справочнике)
-- =============================================
CREATE FUNCTION [dbo].[IS_STREET_CORRECT]
(
	-- Add the parameters for the function here
	@street varchar(100)
)
RETURNS int
AS
BEGIN
  DECLARE @prefix varchar(50)
  DECLARE @name varchar(100)

  SET @prefix = ''
  SET @name = ''

  SET @street = LTRIM(RTRIM(@street))

  IF CHARINDEX('.', @street) <> 0 
    BEGIN
        -- есть точка, значит скорее всего есть префикс. До точки включительно - префикс
      SET @prefix = LEFT(@street, CHARINDEX('.', @street))
      SET @street = RIGHT(@street, LEN(@street) - CHARINDEX('.', @street))        
       
      SET @street = LTRIM(RTRIM(@street))
      SET @name = @street
      END
    ELSE
      BEGIN
        SET @name = @street
        SET @prefix = '' 
      END
	
    IF EXISTS(SELECT * FROM StreetTable WHERE ST_NAME = @name)
      RETURN 0
    ELSE
      RETURN 1

  RETURN 1

END


