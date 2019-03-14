USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ���������� ID ���������������� 
               �������� � ��������� ���������. 
*/

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_CHECK_NAME] 
	@technoltypename VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	SELECT TT_ID
	FROM dbo.TechnolTypeTable
	WHERE TT_NAME = @technoltypename

	SET NOCOUNT OFF
END