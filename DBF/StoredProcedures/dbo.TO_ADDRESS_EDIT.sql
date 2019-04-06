USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[TO_ADDRESS_EDIT]
	@taid INT,	
	@index VARCHAR(20),
	@streetid SMALLINT,	
	@home VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.TOAddressTable
	SET		
		TA_INDEX = @index, 
		TA_ID_STREET = @streetid, 
		TA_HOME = @home
	WHERE TA_ID = @taid
	
	SET NOCOUNT OFF
END