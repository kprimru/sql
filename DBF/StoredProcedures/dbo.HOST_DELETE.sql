USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ������� ���� � ��������� 
               ����� �� �����������
*/

CREATE PROCEDURE [dbo].[HOST_DELETE] 
	@hostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.HostTable WHERE HST_ID = @hostid

	SET NOCOUNT OFF
END


