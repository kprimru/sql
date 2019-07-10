USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:		������� �������
��������:	
*/

CREATE TRIGGER [dbo].[IncomeDistrInsert]
   ON  [dbo].[IncomeDistrTable]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;	

	INSERT INTO SaldoTable(
						SL_DATE, SL_ID_CLIENT, SL_ID_DISTR, 
						SL_ID_BILL_DIS, SL_ID_IN_DIS, SL_ID_ACT_DIS, SL_REST, SL_TP, SL_BEZ_NDS)
		SELECT 
			ID_DATE, IN_ID_CLIENT, ID_ID_DISTR, NULL, ID_ID, NULL, 
			ISNULL(
				(
					SELECT TOP 1 SL_REST
					FROM SaldoTable
					WHERE SL_ID_DISTR = ID_ID_DISTR
						AND SL_ID_CLIENT = IN_ID_CLIENT								
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) + ID_PRICE, 1,
			ISNULL(
				(
					SELECT TOP 1 SL_BEZ_NDS
					FROM SaldoTable
					WHERE SL_ID_DISTR = ID_ID_DISTR
						AND SL_ID_CLIENT = IN_ID_CLIENT								
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) + ROUND(ID_PRICE * 100 / (100 + TX_PERCENT), 2)
		FROM 
			INSERTED INNER JOIN
			IncomeTable ON IN_ID = ID_ID_INCOME
			INNER JOIN dbo.DistrView ON DIS_ID = ID_ID_DISTR
			INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
			INNER JOIN dbo.TaxTable ON TX_ID = SO_ID_TAX
END
