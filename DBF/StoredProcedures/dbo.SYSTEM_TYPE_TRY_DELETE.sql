USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ��� ������� 
               ����� �������, 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_TRY_DELETE] 
	@systemtypeid SMALLINT
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 28.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_TYPE = @systemtypeid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '���������� ������� ��� �������, ��� ��� � ��� ��� ��������������� �����������.'
	  END
	IF EXISTS(SELECT * FROM dbo.ClientSystemHistoryTable WHERE CSH_ID_TYPE = @systemtypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��� �������, ��� ��� '
							+ '������� ������ � ������� ������ ������� � ������ �����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_TYPE = @systemtypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��� �������, ��� ��� '
							+ '������� ������ � ������� ���.���� � ������ �����.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_TECH_TYPE = @systemtypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��� �������, ��� ��� '
					+ '������� ������ � ����������� ����� ������ � ������ �����.'
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF

END









