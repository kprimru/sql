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

CREATE PROCEDURE [dbo].[TO_ADDRESS_DELETE] 
	@toadid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.TOAddressTable 
	WHERE TA_ID = @toadid

	SET NOCOUNT OFF
END




