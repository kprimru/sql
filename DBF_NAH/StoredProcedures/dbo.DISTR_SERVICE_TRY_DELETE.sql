USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[DISTR_SERVICE_TRY_DELETE]
	@dsid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 30.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_SERVICE = @dsid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '�������� ����������, ��� ��� ��������� ������ ������������ �������� '
							+ '������-�� ������������ ���������� �������.'
							+ CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTR_SERVICE_TRY_DELETE] TO rl_distr_service_d;
GO