USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 02.10.2008
-- ��������:	  ���������� �������� ��������
--                �� ����������� �� ���.����
-- =============================================
ALTER FUNCTION [dbo].[GET_HOST_BY_COMMENT]
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



