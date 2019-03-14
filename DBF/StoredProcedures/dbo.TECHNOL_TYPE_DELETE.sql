USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 24.09.2008
��������:	  ������� ��� ������� � ��������� 
               ����� �� �����������
*/

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_DELETE] 
	@technoltypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.TechnolTypeTable 
	WHERE TT_ID = @technoltypeid

	SET NOCOUNT OFF
END