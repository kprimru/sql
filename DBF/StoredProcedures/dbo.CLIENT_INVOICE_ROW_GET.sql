USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	1.04.2009
Описание:		строка таблицы счета-фактуры
*/

CREATE PROCEDURE [dbo].[CLIENT_INVOICE_ROW_GET]
	@rowid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		INR_ID, DIS_ID, DIS_STR, INR_GOOD, INR_NAME, INR_SUM, 
		INR_ID_TAX, INR_TNDS, INR_SNDS, INR_SALL, INR_UNIT, INR_COUNT,
		PR_ID, PR_NAME
	FROM 
		dbo.InvoiceRowTable 
		LEFT OUTER JOIN dbo.DistrView ON INR_ID_DISTR = DIS_ID 
		LEFT OUTER JOIN dbo.PeriodTable ON INR_ID_PERIOD = PR_ID
	WHERE INR_ID = @rowid

END














