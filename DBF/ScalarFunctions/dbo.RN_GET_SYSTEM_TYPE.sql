USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 29.10.2008
-- Описание:	  Выделяет ID типа системы
-- =============================================
ALTER FUNCTION [dbo].[RN_GET_SYSTEM_TYPE]
(
  @systype VARCHAR(20)
)
RETURNS INT
AS
BEGIN
  DECLARE @result INT

  SET @result = NULL

  SELECT @result = SST_ID FROM dbo.SystemTypeTable WHERE SST_NAME = @systype

  RETURN @result

END



GO
