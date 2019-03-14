USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ���������� 0, ���� ��������������� �������
               ����� �������, 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_TRY_DELETE] 
	@technoltypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 28.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��������������� �������, ��� ��� � ��� ��� ��������������� �����������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.RegNodeTable WHERE RN_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��������������� �������, ��� ��� '
							+ '� ��� ��� ��������������� �����������.'  + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��������������� �������, ��� ��� '
							+ '������� ������ � ������� ���.���� � ������ ���������.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��������������� �������, ��� ��� '
					+ '������� ������ � ����������� ����� ������ � ������ ���������.'
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END