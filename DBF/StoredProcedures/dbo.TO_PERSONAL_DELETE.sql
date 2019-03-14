USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
��������:	  ������� ������� � ����������� ��������� ��.
*/

CREATE PROCEDURE [dbo].[TO_PERSONAL_DELETE] 
	@personalid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.TOPersonalTable 
	WHERE TP_ID = @personalid

	SET NOCOUNT OFF
END