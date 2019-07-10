USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 16.10.2008
��������:	  ���������� 0, ���� ������� ����� 
               ������� �� ����������� (�� � 
               ����� ������� �� �� ������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[SUBHOST_TRY_DELETE] 
	@subhostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_HOST = @subhostid)
		BEGIN
			-- �������� 4.05.2009
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
							+ '������� ������ � ������� ���.���� � ������ ���������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_HOST = @subhostid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
							+ '������� ������ � ����������� ����� ������ � ������ ���������.' + CHAR(13)
		END

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� ��� �������� �������. ' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� �� ������ �� ���.����.'
		END
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, �� ���� ��������� ������ � ������� ���������.'
		END
	
	-- 

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END


