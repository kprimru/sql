USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
��������:	  ���������� 0, ���� ��� �������� � 
                ��������� ����� ����� ������� 
                (�� ��� �� ��������� �� ���� 
                ������� �������), 
                -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[CONTRACT_PAY_TRY_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_PAY = @id)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ��� ������ � ������ ��� ���������� ���������. ' + 
						  '�������� ����������, ���� ��������� ��� ����� ������ ���� ' +
						  '�� � ����� ��������.'
	  END

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END