USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������������� 
               ����������� � ��������� ����� ����� 
               ������� �� ����������� (��� �� 
               ������� �� � ������ �������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[ORGANIZATION_TRY_DELETE] 
	@organizationid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ����������� ������� � ������ ��� ���������� ��������. ' + 
							  '�������� ����������, ���� ��������� ����������� ����� ������� ���� ' +
							  '�� � ������ �������.'
		END

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
								'���������� �� ��� ����������� ����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
								'���������� �� ��� ����������� �����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
								'����������� �� ��� ����������� �������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
								'���������� �� ��� ����������� �����-�������.' + CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END
