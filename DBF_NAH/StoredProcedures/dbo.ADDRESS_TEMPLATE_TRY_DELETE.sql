USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� �������
��������:
����:			16.07.2009
*/
ALTER PROCEDURE [dbo].[ADDRESS_TEMPLATE_TRY_DELETE]
	@atlid TINYINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

/*	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_TEMPLATE = @atlid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ������ ������ ������ � ����� ��� ���������� �������. ' +
							  '�������� ����������, ���� ��������� ������ ������ ����� ������ ���� ' +
							  '�� � ����� ������.'
		END
*/
	SELECT @res AS RES, @txt AS TXT
END
GO
GRANT EXECUTE ON [dbo].[ADDRESS_TEMPLATE_TRY_DELETE] TO rl_address_template_d;
GO