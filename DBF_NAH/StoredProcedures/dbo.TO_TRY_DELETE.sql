USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������
��������:		����� ���� ����� ������������ ���������� �������
*/

ALTER PROCEDURE [dbo].[TO_TRY_DELETE]
	@toid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.TODistrTable WHERE TD_ID_TO = @toid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� ��, ��� ��� �� �������� ������������.'
	  END

	IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID = @toid AND TO_REPORT = 1)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� ��, ��� ��� ��� �������� � �����.'
	  END

	IF EXISTS(SELECT * FROM dbo.TOPersonalTable WHERE TP_ID_TO = @toid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� ��, ��� ��� �� �������� ����������.'
	  END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[TO_TRY_DELETE] TO rl_to_d;
GO