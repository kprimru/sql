USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 29.10.2008
-- ��������:	  �������� ID ��������
-- =============================================
ALTER FUNCTION [dbo].[RN_GET_SUBHOST_ID]
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
