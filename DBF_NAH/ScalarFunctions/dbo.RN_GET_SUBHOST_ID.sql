﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_SUBHOST_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_SUBHOST_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO

-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 29.10.2008
-- Описание:	  Выделяет ID подхоста
-- =============================================
CREATE FUNCTION [dbo].[RN_GET_SUBHOST_ID]
(
  @comment VARCHAR(150),
  @subsign BIT
)
RETURNS INT
AS
BEGIN
  DECLARE @result INT

  SET @result = NULL

  DECLARE @subhoststr VARCHAR(150)

  --IF @subsign = 1
    --BEGIN
      SET @comment = dbo.GET_HOST_BY_COMMENT(@comment)
      SELECT @result = SH_ID FROM dbo.SubhostTable WHERE SH_LST_NAME = @comment AND SH_REG = 1
    --END
  --ELSE
    --BEGIN
      --SELECT @result = SH_ID FROM dbo.SubhostTable WHERE SH_SUBHOST = 0
    --END

  RETURN @result
END






GO
