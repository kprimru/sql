﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_HOST_BY_COMMENT]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_HOST_BY_COMMENT] () RETURNS Int AS BEGIN RETURN NULL END')
GO



-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 02.10.2008
-- Описание:	  Возвращает название подхоста
--                по комментарию из рег.узла
-- =============================================
CREATE FUNCTION [dbo].[GET_HOST_BY_COMMENT]
(
  @comment varchar(200)
)
RETURNS varchar(10)
AS
BEGIN
  DECLARE @res varchar(10)

  SET @res = ''

  DECLARE @temp varchar(200)

  SET @comment = ISNULL(@comment, '')

  IF CHARINDEX('(', @comment) <> 1
    RETURN @res

  SET @temp = SUBSTRING(@comment, CHARINDEX('(', @comment) + 1,
                        LEN(@comment) - CHARINDEX('(', @comment))

  IF CHARINDEX(')', @temp) < 2
    RETURN @res

  SET @temp = SUBSTRING(@temp, 1, CHARINDEX(')', @temp) - 1)

  RETURN @temp
END




GO
