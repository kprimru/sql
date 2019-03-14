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

CREATE PROCEDURE [dbo].[ACTIVITY_TRY_DELETE] 
	@activityid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_ACTIVITY = @activityid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ��� ������������ ������ � ������ ��� ���������� ��������. ' + 
							  '�������� ����������, ���� ��������� ��� ������������ ����� ������ ���� ' +
							  '�� � ������ �������.'
		END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END






