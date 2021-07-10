USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:	4.05.2009
��������:		�������� �� ������� ������� ������������ � �������� ������
				(����� ������ �� �����)
*/

ALTER PROCEDURE [dbo].[DISTR_STATUS_CHECK_NAME]
	@dsname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT DS_ID
	FROM dbo.DistrStatusTable
	WHERE DS_NAME = @dsname

	SET NOCOUNT OFF
END








GO
GRANT EXECUTE ON [dbo].[DISTR_STATUS_CHECK_NAME] TO rl_distr_status_w;
GO