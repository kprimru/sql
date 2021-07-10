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

ALTER PROCEDURE [dbo].[CLIENT_TRY_DELETE]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_CLIENT = @clientid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �������, ��� ��� ��� �������� ������������.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_CLIENT = @clientid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �������, ��� ��� ��� �������� ������.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_CLIENT = @clientid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� ������������, ��� ��� ��� �������� ��������.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.ClientPersonalTable WHERE PER_ID_CLIENT = @clientid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �������, ��� ��� ��� �������� ����������.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID_CLIENT = @clientid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �������, ��� ��� ��� �������� ��.' + CHAR(13)
	  END

	-- ��������� 30.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_CLIENT = @clientid)
		BEGIN
			SET @txt = @txt	+	'���������� ������� �������, ��� ��� ���������� ' +
								'���������� �� ���� ����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_CLIENT = @clientid)
		BEGIN
			SET @txt = @txt	+	'���������� ������� �������, ��� ��� ���������� ' +
								'���������� �� ���� �����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_CLIENT = @clientid)
		BEGIN
			SET @txt = @txt	+	'���������� ������� �������, ��� ��� ���������� ' +
								'����������� �� ���� �������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_CLIENT = @clientid)
		BEGIN
			SET @txt = @txt	+	'���������� ������� �������, ��� ��� ���������� ' +
								'���������� �� ���� �����-�������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.SaldoTable WHERE SL_ID_CLIENT = @clientid)
		BEGIN
			SET @txt = @txt	+	'���������� ������� �������, ��� ��� �� ���� ������� ' +
								'������ � ������.' + CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END










GO
GRANT EXECUTE ON [dbo].[CLIENT_TRY_DELETE] TO rl_client_d;
GO