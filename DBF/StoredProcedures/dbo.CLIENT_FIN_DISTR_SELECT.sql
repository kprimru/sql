USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[CLIENT_FIN_DISTR_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DIS_ID, DIS_STR, DSS_REPORT, DSS_NAME
	FROM dbo.ClientDistrView
	WHERE --DSS_REPORT = 1 
		--AND 
		CD_ID_CLIENT = @clientid
	ORDER BY DSS_REPORT DESC, DIS_STR
END
