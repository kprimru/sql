USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:         ������� �������
��������:      ������� ����������� �� ������ ������������� �������
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_DELETE]
	@id INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.ClientDistrTable
	WHERE CD_ID = @id

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DELETE] TO rl_client_distr_d;
GO