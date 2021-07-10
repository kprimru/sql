USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:         ������� �������
��������:      ������� ������ � ������������ ������� � ��������� �����
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_GET]
	@clientdistrid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		CD_ID, DIS_ID, DIS_STR, CD_REG_DATE, DSS_NAME, DSS_ID
	FROM dbo.ClientDistrView
	WHERE CD_ID = @clientdistrid

	SET NOCOUNT OFF
END










GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_GET] TO rl_client_distr_r;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_GET] TO rl_client_r;
GO