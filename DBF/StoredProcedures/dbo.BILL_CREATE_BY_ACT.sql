USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[BILL_CREATE_BY_ACT]
	@actid INT,
	@billdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.BillTable(BL_ID_CLIENT, BL_ID_PERIOD, BL_ID_ORG)
		SELECT DISTINCT ACT_ID_CLIENT, AD_ID_PERIOD, ACT_ID_ORG
		FROM 
			dbo.ActTable INNER JOIN
			dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
		WHERE ACT_ID = @actid
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.BillTable
					WHERE BL_ID_CLIENT = ACT_ID_CLIENT
						AND BL_ID_PERIOD = AD_ID_PERIOD
				)

	INSERT INTO dbo.BillDistrTable(
			BD_ID_BILL, BD_ID_DISTR, BD_ID_TAX, 
			BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_DATE
				)
		SELECT 
			(
				SELECT BL_ID
				FROM dbo.BillTable
				WHERE BL_ID_CLIENT = ACT_ID_CLIENT
					AND BL_ID_PERIOD = AD_ID_PERIOD
			), 
			AD_ID_DISTR, AD_ID_TAX, 
			AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE, @billdate
		FROM 
			dbo.ActTable INNER JOIN
			dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
		WHERE ACT_ID = @actid
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.BillDistrTable
					WHERE BD_ID_BILL = 
						(
							SELECT BL_ID
							FROM dbo.BillTable
							WHERE BL_ID_CLIENT = ACT_ID_CLIENT
								AND BL_ID_PERIOD = AD_ID_PERIOD
						) AND BD_ID_DISTR = AD_ID_DISTR
				)
END
