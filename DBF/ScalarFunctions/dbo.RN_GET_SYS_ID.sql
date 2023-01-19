USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_SYS_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_SYS_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO



-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 29.10.2008
-- Описание:	  Выделяет ID системы из строки
--                регузла
-- =============================================
CREATE FUNCTION [dbo].[RN_GET_SYS_ID]
(
  @regname VARCHAR(50)
)
RETURNS INT
AS
BEGIN
  DECLARE @result INT

  SET @result = NULL

  SELECT @result = SYS_ID
  FROM dbo.SystemTable
  WHERE SYS_REG_NAME = @regname

  RETURN @result

END



GO
