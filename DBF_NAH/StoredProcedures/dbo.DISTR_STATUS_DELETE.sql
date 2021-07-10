USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 30.01.2009
��������:	  ������� ������ ������������
*/

ALTER PROCEDURE [dbo].[DISTR_STATUS_DELETE]
	@distrstatusid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.DistrStatusTable
	WHERE DS_ID = @distrstatusid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTR_STATUS_DELETE] TO rl_distr_status_d;
GO