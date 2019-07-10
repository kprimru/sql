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

CREATE PROCEDURE [dbo].[TO_GET]	
	@toid INT   
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT 
		TO_NAME, TO_ID, TO_NUM, TO_REPORT, COUR_ID, TO_VMI_COMMENT, TO_MAIN,
		COUR_NAME, TA_INDEX, TA_HOME, ST_ID, ST_NAME, ST_CITY_NAME, CL_INN, TO_INN, TO_PARENT
	FROM 
		dbo.TOView a LEFT OUTER JOIN
		dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
	WHERE TO_ID = @toid

	SET NOCOUNT OFF		
END