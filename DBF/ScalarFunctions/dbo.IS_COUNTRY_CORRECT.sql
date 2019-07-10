USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Возвращает 0, если название страны 
--                корректно (присутствует в справочнике)
-- =============================================
CREATE FUNCTION [dbo].[IS_COUNTRY_CORRECT]
(
	@country varchar(100)
)
RETURNS int
AS
BEGIN
  IF EXISTS(SELECT * FROM CountryTable WHERE CNT_NAME = LTRIM(RTRIM(@country)))
    RETURN 0
  ELSE
    RETURN 1

  RETURN 1

END

