USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[BILL_DISTR_GET]
	@bdid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DIS_ID, DIS_STR, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_DATE, PR_ID, PR_DATE
	FROM dbo.BillDistrView
	WHERE BD_ID = @bdid
END