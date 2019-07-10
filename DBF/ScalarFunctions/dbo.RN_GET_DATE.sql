USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 29.10.2008
-- Описание:	  Выделяет дату регистрации
-- =============================================
CREATE FUNCTION [dbo].[RN_GET_DATE]
(
  @regdate VARCHAR(20)
)
RETURNS SMALLDATETIME
AS
BEGIN
  DECLARE @result DATETIME

  SET @result = '19000101'
  
  IF ISDATE(@regdate) = 1
    SET @result = CONVERT(DATETIME, @regdate, 104)
  ELSE
    SET @result = '19000101'

  RETURN @result
END



