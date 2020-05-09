USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- �����:			��������� �������
-- ���� ��������:	19.02.2009
-- ��������:		�������� ID ���������� ������� �������
--					�� ������ �������
-- ================================================
ALTER FUNCTION [dbo].[RN_GET_NET_ID]
(
  @netcount VARCHAR(50)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @result SMALLINT

	SET @result = NULL

	SELECT	@result = SNC_ID
	FROM	dbo.SystemNetCountTable
	WHERE	SNC_NET_COUNT = @netcount

	RETURN @result

END




GO
