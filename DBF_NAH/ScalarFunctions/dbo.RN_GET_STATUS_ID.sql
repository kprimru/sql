USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- �����:			��������� �������
-- ���� ��������:	19.02.2009
-- ��������:		�������� ID ������� ������������
--					�� ������ �������
-- ================================================
ALTER FUNCTION [dbo].[RN_GET_STATUS_ID]
(
  @status VARCHAR(50)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @result SMALLINT

	SET @result = NULL

	SELECT	@result = DS_ID
	FROM	dbo.DistrStatusTable
	WHERE	DS_REG = @status

	RETURN @result

END






GO
