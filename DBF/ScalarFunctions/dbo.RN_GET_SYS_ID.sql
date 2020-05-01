USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 29.10.2008
-- ��������:	  �������� ID ������� �� ������
--                �������
-- =============================================
ALTER FUNCTION [dbo].[RN_GET_SYS_ID]
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



