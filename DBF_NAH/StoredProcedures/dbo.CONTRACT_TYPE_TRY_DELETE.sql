USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  ���������� 0, ���� ��� �������� �
                ��������� ����� ����� �������
                (�� ��� �� ��������� �� ����
                ������� �������),
                -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[CONTRACT_TYPE_TRY_DELETE]
	@contracttypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_TYPE = @contracttypeid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ��� ������ � ������ ��� ���������� ���������. ' +
						  '�������� ����������, ���� ��������� ��� ����� ������ ���� ' +
						  '�� � ����� ��������.'
	  END

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_TYPE_TRY_DELETE] TO rl_contract_type_d;
GO