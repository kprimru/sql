USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  ������� ������ � ��������� 
               ����� �� �����������
*/
CREATE PROCEDURE [dbo].[QUARTER_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.Quarter
	WHERE QR_ID = @id
END
