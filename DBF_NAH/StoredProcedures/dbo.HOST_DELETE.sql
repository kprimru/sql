USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ������� ���� � ���������
               ����� �� �����������
*/

ALTER PROCEDURE [dbo].[HOST_DELETE]
	@hostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.HostTable WHERE HST_ID = @hostid

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[HOST_DELETE] TO rl_host_d;
GO