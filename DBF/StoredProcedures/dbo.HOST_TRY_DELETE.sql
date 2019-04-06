USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� 0, ���� ���� 
               ����� �������, 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[HOST_TRY_DELETE] 
	@hostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.SystemTable WHERE SYS_ID_HOST = @hostid) 
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ���� ������ � ����� ��� ���������� ������. ' + 
						  '�������� ����������, ���� ��������� ���� ����� ������ ���� ' +
						  '�� � ����� �������.'
	  END
	      
	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END