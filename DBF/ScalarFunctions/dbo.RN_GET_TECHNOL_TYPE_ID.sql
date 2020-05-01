USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 18.12.2008
-- Описание:	  Выделяет ID технологического 
--                признака из регузла
-- =============================================
ALTER FUNCTION [dbo].[RN_GET_TECHNOL_TYPE_ID]
(
  @regdata INT
)
RETURNS INT
AS
BEGIN
  DECLARE @result INT  
  
  SET @result = NULL

  SELECT @result = TT_ID 
  FROM dbo.TechnolTypeTable 
  WHERE TT_REG = @regdata
  
  RETURN @result

END




