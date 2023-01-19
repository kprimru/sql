USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_SYSTEM_TYPE]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_SYSTEM_TYPE] () RETURNS Int AS BEGIN RETURN NULL END')
GO


-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 29.10.2008
-- Описание:	  Выделяет ID типа системы
-- =============================================
CREATE FUNCTION [dbo].[RN_GET_SYSTEM_TYPE]
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
