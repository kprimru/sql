USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 25.08.2008
-- ��������:	  ���������� 0, ���� �������� ������
--                ���������, �� ���� ������������ 
--                � �����������
-- =============================================
CREATE FUNCTION [dbo].[IS_AREA_CORRECT]
(
	@area varchar(100)	
)
RETURNS int
AS
BEGIN
  SET @area = LTRIM(RTRIM(@area))

  IF EXISTS(SELECT * FROM AreaTable WHERE AR_NAME = @area)
    RETURN 0
  ELSE
    RETURN 1

  RETURN 1
END

