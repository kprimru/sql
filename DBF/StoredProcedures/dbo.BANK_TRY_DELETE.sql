USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[BANK_TRY_DELETE] 
	@bankid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_BANK = @bankid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ���� ������ � ������ ��� ���������� ��������. ' + 
							  '�������� ����������, ���� ��������� ���� ����� ������ ���� ' +
							  '�� � ������ �������.' + CHAR(13)
		END

	-- ��������� 30.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_BANK = @bankid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ���� ������ � ����� ��� ���������� ������������� �����������. ' + 
							  '�������� ����������, ���� ��������� ���� ����� ������ ���� ' +
							  '�� � ����� ������������� �����������.' + CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END

