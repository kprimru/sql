USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 19.11.2008
��������:	  ���������� 0, ���� ������� ����� 
                ������� �� ����������� (�� � 
               ����� ������� �� �� ������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_TRY_DELETE] 
	@swid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''


	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END