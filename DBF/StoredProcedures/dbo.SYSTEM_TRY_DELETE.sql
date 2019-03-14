USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������� ����� 
               ������� �� ����������� (�� � 
               ������ ������� ��� ����� �������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[SYSTEM_TRY_DELETE] 
	@systemid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.DistrTable WHERE DIS_ID_SYSTEM = @systemid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� ���������� ' +
							+ '������������ ���� �������.' + CHAR(13)
		END

	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_SYSTEM = @systemid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
							+ '������� ������ � ������� ���.���� � ������ ��������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_SYSTEM = @systemid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
					+ '������� ������ � ����������� ����� ������ � ������ ��������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_SYSTEM = @systemid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
					+ '������� ������ � ������������ � ������ �������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PriceSystemHistoryTable WHERE PSH_ID_SYSTEM = @systemid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� '
					+ '������� ������ � ������� ��� ������ �������.' + CHAR(13)
		END

	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_SYSTEM = @systemid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� �������, ��� ��� ��� ��� ����������������.'
	  END

	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END






