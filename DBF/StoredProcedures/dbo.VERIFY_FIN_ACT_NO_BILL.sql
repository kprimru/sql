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

CREATE PROCEDURE [dbo].[VERIFY_FIN_ACT_NO_BILL]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE
	FROM
		dbo.ActTable a INNER JOIN
		dbo.ActDistrTable b ON ACT_ID = AD_ID_ACT INNER JOIN
		dbo.ClientTable ON CL_ID = ACT_ID_CLIENT INNER JOIN
		dbo.DistrView ON DIS_ID = AD_ID_DISTR INNER JOIN
		dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
	WHERE NOT EXISTS
		(
			SELECT * FROM 
				dbo.BillDistrTable c INNER JOIN
				dbo.BillTable d ON BD_ID_BILL = BL_ID
			WHERE 
				c.BD_ID_DISTR = b.AD_ID_DISTR 
				AND d.BL_ID_CLIENT = a.ACT_ID_CLIENT
				AND d.BL_ID_PERIOD = b.AD_ID_PERIOD
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE
	FROM
		dbo.ConsignmentTable a INNER JOIN
		dbo.ConsignmentDetailTable b ON CSG_ID = CSD_ID_CONS INNER JOIN
		dbo.ClientTable ON CL_ID = CSG_ID_CLIENT INNER JOIN
		dbo.DistrView ON DIS_ID = CSD_ID_DISTR INNER JOIN
		dbo.PeriodTable ON PR_ID = CSD_ID_PERIOD
	WHERE NOT EXISTS
		(
			SELECT * FROM 
				dbo.BillDistrTable c INNER JOIN
				dbo.BillTable d ON BD_ID_BILL = BL_ID
			WHERE 
				c.BD_ID_DISTR = b.CSD_ID_DISTR 
				AND d.BL_ID_CLIENT = a.CSG_ID_CLIENT
				AND d.BL_ID_PERIOD = b.CSD_ID_PERIOD
		)

	ORDER BY CL_PSEDO, DIS_STR, PR_DATE

END
