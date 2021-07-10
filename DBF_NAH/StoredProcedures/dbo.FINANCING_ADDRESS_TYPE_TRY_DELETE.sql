USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� �������
���� ��������:	3 July 2009
��������:		���������� 0, ���� ��� ������ � ���. ���������
				� ��������� ����� ����� ������� ��
				�����������,
				-1 � ��������� ������
*/
ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_TRY_DELETE]
	@fatid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

/*
	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_FIN = @financingid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ��� �������������� ������ � ������ ��� ���������� ��������. ' +
						  '�������� ����������, ���� ��������� ��� �������������� ����� ������ ���� ' +
						  '�� � ������ �������.'
	  END
*/

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_TRY_DELETE] TO rl_financing_address_type_d;
GO