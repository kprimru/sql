USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  19/10/2009	
Описание:		get-процедура для формы редактирования счетов (бывш. фактич. счета)
*/

CREATE PROCEDURE [dbo].[CLIENT_BILL_FACT_ROW_SELECT]
	@bfmid INT	
AS
BEGIN
	SET NOCOUNT ON;
	/*
	DECLARE @d DATETIME
	SET @d = CONVERT(DATETIME, @date, 121)
	*/

	SELECT 
		BFD_ID, 
		BFD_ID_BFM, 
		BILL_STR, 
		TX_PERCENT, 
		TX_NAME, 
		a.SYS_NAME, 
		a.SYS_ORDER, 
		a.DIS_ID, 
		a.DIS_NUM, 
		DIS_STR,
		PR_ID, 
		PR_MONTH, 
		PR_DATE, 
		BD_UNPAY, 
		BD_TAX_UNPAY, 
		BD_TOTAL_UNPAY
	FROM 
		dbo.BillFactDetailTable a 
		LEFT OUTER JOIN
		dbo.DistrView b ON a.DIS_ID = b.DIS_ID
	WHERE BFD_ID_BFM = @bfmid

END



