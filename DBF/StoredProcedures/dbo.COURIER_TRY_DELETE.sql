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
CREATE PROCEDURE [dbo].[COURIER_TRY_DELETE] 
	@courierid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''
	
	-- �������� 30.04.2009, �.������
	
	/*IF EXISTS(SELECT * FROM dbo.CLientTable WHERE CL_ID_COUR = @courierid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ������-������� ������ � ������ ��� ���������� ��. ' + 
						  '�������� ����������, ���� ��������� ������-������� ����� ������ ���� ' +
						  '�� � ����� ��.'
	  END
	*/
	-- �������� ��:
	IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID_COUR = @courierid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ������-������� ������ � ������ ��� ���������� ��. ' + 
							  '�������� ����������, ���� ��������� ������-������� ����� ������ ���� ' +
							  '�� � ����� ��.'
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END