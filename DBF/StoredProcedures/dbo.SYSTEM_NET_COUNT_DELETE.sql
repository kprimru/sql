USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 23.09.2008
��������:	  ������� ������ � ���-�� ������� 
               ���� ���� � ��������� ID �� �����������
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_DELETE] 
	@systemnetcountid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemNetCountTable WHERE SNC_ID = @systemnetcountid

	SET NOCOUNT OFF
END