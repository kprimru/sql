USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
�����:			������� �������/������ ��������
��������:		
*/

CREATE PROCEDURE [dbo].[CLIENT_INCOME_REST_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF DB_ID('DBF_NAH') IS NOT NULL
		SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, (SELECT COUNT(*) FROM DBF_NAH.dbo.ClientTable z WHERE z.CL_NUM = a.CL_NUM) AS CL_NAH,
			UNKNOWN_FINANCING
		FROM dbo.ClientTable a LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
		WHERE EXISTS
			(
				SELECT * 
				FROM dbo.IncomeView
				WHERE IN_ID_CLIENT = CL_ID AND IN_REST <> 0
			)
		ORDER BY CL_PSEDO
	ELSE
		SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, 0 AS CL_NAH,
			UNKNOWN_FINANCING
		FROM dbo.ClientTable LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
		WHERE EXISTS
			(
				SELECT * 
				FROM dbo.IncomeView
				WHERE IN_ID_CLIENT = CL_ID AND IN_REST <> 0
			)
		ORDER BY CL_PSEDO, CL_ID
	
END




