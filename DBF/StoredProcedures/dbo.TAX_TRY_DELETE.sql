USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������, ������ ��������
���� ��������: 27.01.2009
��������:	  ���������� 0, ���� ����� ������� 
               �����, 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[TAX_TRY_DELETE] 
	@taxid SMALLINT
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 28.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �����, ��� ��� ���������� ������ � ��������� ������ � ���� �������. '
	  END

	IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ����-������� � ���� �������. '
	  END

	IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ����� � ���� �������. '
	  END

	IF EXISTS(SELECT * FROM dbo.SaleObjectTable WHERE SO_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ������� ������ � ���� �������. '
	  END

	IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ���� � ���� �������. '
	  END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF

END

