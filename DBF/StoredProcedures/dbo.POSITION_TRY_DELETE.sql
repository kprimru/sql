USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, � ������ ���� 
               ��������� ����� ������� 
               (��� �� ������� �� � ������ ����������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[POSITION_TRY_DELETE] 
	@positionid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientPersonalTable WHERE PER_ID_POS = @positionid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ��������� ������� � ������ ��� ���������� ����������� �������. ' + 
						  '�������� ����������, ���� ��������� ��������� ����� ������ ���� ' +
						  '�� � ������ ����������.'
	  END
	
	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.TOPersonalTable WHERE TP_ID_POS = @positionid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ��������� ������� � ������ ��� ���������� ����������� �� �������. ' + 
						  '�������� ����������, ���� ��������� ��������� ����� ������ ���� ' +
						  '�� � ������ ����������.'
	  END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
