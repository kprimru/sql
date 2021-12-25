﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Возвращает 0, если индекс корректен
--                (состоит из 6 цифр)
-- =============================================
ALTER FUNCTION [dbo].[IS_INDEX_CORRECT]
(
	@index varchar(50)
)
RETURNS int
AS
BEGIN
	IF LEN(@index) <> 6
      RETURN 1

    WHILE LEN(@index) > 0
      BEGIN
        IF NOT(SUBSTRING(@index, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9'))
          RETURN 1

        SET @index = RIGHT(@index, LEN(@index) - 1)
      END

	RETURN 0

END




GO
