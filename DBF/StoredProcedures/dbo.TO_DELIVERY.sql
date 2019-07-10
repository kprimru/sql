USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[TO_DELIVERY]
	@toid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	-- ��������� ����� ������������ � ������� �������

	UPDATE dbo.TOTable
	SET TO_ID_CLIENT = @clientid	
	WHERE TO_ID = @toid

	-- ��������� ������������ �� �� � �������
	UPDATE dbo.ClientDistrTable 
	SET CD_ID_CLIENT = @clientid
	WHERE 
		EXISTS
			(
				SELECT * 
				FROM dbo.TODistrTable 
				WHERE TD_ID_TO = @toid 
					AND CD_ID_DISTR = TD_ID_DISTR
			)	
END