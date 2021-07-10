USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[INVOICE_FACT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IFM_DATE
	FROM dbo.InvoiceFactMasterTable
	GROUP BY IFM_DATE
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_FACT_SELECT] TO rl_invoice_p;
GO