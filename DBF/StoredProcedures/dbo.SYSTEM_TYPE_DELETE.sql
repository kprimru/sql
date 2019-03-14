USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ������� ��������������� ������� 
               � ��������� ����� �� �����������
*/

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_DELETE] 
	@systemtypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.SystemTypeTable 
	WHERE SST_ID = @systemtypeid

	SET NOCOUNT OFF
END