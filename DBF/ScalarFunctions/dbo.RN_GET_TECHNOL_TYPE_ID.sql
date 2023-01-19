USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_TECHNOL_TYPE_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_TECHNOL_TYPE_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO

-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 18.12.2008
-- Описание:	  Выделяет ID технологического
--                признака из регузла
-- =============================================
CREATE FUNCTION [dbo].[RN_GET_TECHNOL_TYPE_ID]
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




GO
