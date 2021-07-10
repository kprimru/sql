USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ����� � ���������
               ����� ����� ������� �� �����������
               (�� ��� �� ��������� �� ���� �����),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[STREET_TRY_DELETE]
	@streetid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_STREET = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ��������. '
	  END

	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_STREET = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ������������� �����������.'
	  END
	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_S_ID_STREET	 = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ������������� �����������.'
	  END

	IF EXISTS(SELECT * FROM dbo.TOAddressTable WHERE TA_ID_STREET	 = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ����� ������������.'
	  END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[STREET_TRY_DELETE] TO rl_street_d;
GO