USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� 0, ���� ����������� � 
               ��������� ����� ����� ������� �� 
               ������, -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[DISTR_TRY_DELETE] 
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ����������� � ������-�� �������. �������� ����������,'
							+ '���� ��������� ����������� ����������� �������.'
							+ CHAR(13)
		END

	-- ��������� 30.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� ����, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � �����.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.ContractDistrTable WHERE COD_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� �������, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � ��������.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� ���, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � ����.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.IncomeDistrTable WHERE ID_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� ������, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � �������.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� ����-�������, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � ����-�������.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������� ��������� ������, � ������� ������ ������ �����������. �������� ����������,'
							+ '���� ��������� ����������� ������ � ��������� ������.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.TODistrTable WHERE TD_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ����������� ������ � �����-�� ��. �������� ����������,'
							+ '���� ��������� ����������� ����������� ��.'
							+ CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.SaldoTable WHERE SL_ID_DISTR = @distrid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '�������� ����������, ��� ��� ������ ����������� ������ � ������ � ������.'
		END

	--


	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END