USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 25.08.2008
-- ��������:	  ���������� 0, ���� ���������� ����� 
--                ����� ������� �� ����������� (�� 
--                ���� ����� � �� ���� ���� �� ������� 
--                �� ������ ���������� �����), 
--                -1 � ��������� ������
-- =============================================

CREATE PROCEDURE [dbo].[CITY_TRY_DELETE] 
  @cityid int

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.StreetTable WHERE ST_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ���������� ����� ������ � ����� ��� ���������� ����. ' + 
							  '�������� ����������, ���� ��������� ���������� ����� ����� ������ ���� ' +
							  '�� � ����� �����.' + CHAR(13)
		END
	   
	IF EXISTS(SELECT * FROM dbo.BankTable WHERE BA_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ���������� ����� ������ � ������ ��� ���������� ������. ' + 
						  '�������� ����������, ���� ��������� ���������� ����� ����� ������ ���� ' +
						  '�� � ������ �����.' + CHAR(13)
		END

	-- ��������� 4.05.2009
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + '�������� ����������, ��� ��� ������ ���������� �����' 
							+ '������ � ������ ������� ���������.'
		END


	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END

