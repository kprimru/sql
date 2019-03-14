USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:			������� �������
��������:		����� ���� ����� ������������ ���������� �������
*/

CREATE PROCEDURE [dbo].[TO_DELETE]	
	@toid INT   
AS
BEGIN	
	SET NOCOUNT ON;

	DELETE FROM dbo.TOAddressTable WHERE TA_ID_TO = @toid
	DELETE FROM dbo.TOTable WHERE TO_ID = @toid

	SET NOCOUNT OFF		
END