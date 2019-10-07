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
CREATE PROCEDURE [dbo].[CLIENT_BILL_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @bill Table
	(
		BL_ID 			Int,
		PR_ID 			SmallInt,
		SO_ID			SmallInt,
		ORG_ID			SmallInt,
		BL_PRICE		Money,
		PRIMARY KEY CLUSTERED(PR_ID, BL_ID, SO_ID)
	);

	INSERT INTO @Bill(BL_ID, PR_ID, SO_ID, ORG_ID, BL_PRICE)
	SELECT BL_ID, BL_ID_PERIOD, SYS_ID_SO, BL_ID_ORG, ISNULL(SUM(BD_TOTAL_PRICE), 0)
	FROM dbo.BillTable
	INNER JOIN dbo.BillDistrTable ON BL_ID = BD_ID_BILL
	INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
	WHERE BL_ID_CLIENT = @clientid
	GROUP BY BL_ID, BL_ID_PERIOD, SYS_ID_SO, BL_ID_ORG;

	DECLARE @income Table
	(		
		BL_ID 		Int,
		PR_ID 		SmallInt,
		SO_ID 		SmallInt,
		IN_PRICE	Money,
		PRIMARY KEY CLUSTERED(BL_ID, SO_ID)
	)	

	INSERT INTO @income(BL_ID, PR_ID, SO_ID, IN_PRICE)
	SELECT BL_ID, PR_ID, SO_ID, SUM(ID_PRICE)
	FROM dbo.IncomeIXView WITH(NOEXPAND)
	INNER JOIN dbo.BillDistrTable ON ID_ID_DISTR = BD_ID_DISTR
	INNER JOIN dbo.DistrView d WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
	INNER JOIN @bill b ON	b.PR_ID = ID_ID_PERIOD 
						AND BD_ID_BILL = BL_ID 
						AND SYS_ID_SO = b.SO_ID
	WHERE IN_ID_CLIENT = @ClientId
	GROUP BY BL_ID, PR_ID, SO_ID;
		
	SELECT 
    	B.BL_ID, B.PR_ID, PR_DATE, B.BL_PRICE, 
		ISNULL(I.IN_PRICE, 0) AS BL_PAY, 
        SO_NAME, B.SO_ID, 
		BL_PRICE - ISNULL(I.IN_PRICE, 0)AS BL_UNPAY,
		ORG_PSEDO
	FROM @bill							B
	INNER JOIN dbo.OrganizationTable	O ON	B.ORG_ID = O.ORG_ID
	INNER JOIN dbo.PeriodTable			P ON	P.PR_ID = B.PR_ID
	INNER JOIN dbo.SaleObjectTable		S ON	S.SO_ID = B.SO_ID
	LEFT JOIN @income					I ON	I.BL_ID = B.BL_ID
											AND B.SO_ID = I.SO_ID
											AND	I.PR_ID	= B.PR_ID
	ORDER BY PR_DATE DESC;
END