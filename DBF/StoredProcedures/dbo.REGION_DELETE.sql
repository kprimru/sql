USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� ������ � ��������� 
                ����� �� �����������
*/

CREATE PROCEDURE [dbo].[REGION_DELETE] 
	@regionid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.RegionTable 
	WHERE RG_ID = @regionid

	SET NOCOUNT OFF
END
