USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 30.01.2009
��������:	  ���������� 0, ���� ����������� � 
               ��������� ����� ����� ������� �� 
               ������, -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_TRY_DELETE] 
	@dsid SMALLINT
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







