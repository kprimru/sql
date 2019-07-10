USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  7.05.2009
Описание:		
*/

CREATE PROCEDURE [dbo].[CLIENT_FACT_INVOICE_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IFM_DATE, INS_ID, INS_DATE, SUM(INR_SALL) AS IF_TOTAL_PRICE
	FROM	dbo.InvoiceFactMasterTable	A	INNER JOIN
			dbo.InvoiceFactDetailTable	B	ON	B.IFD_ID_IFM=A.IFM_ID
	WHERE CL_ID = @clientid
	GROUP BY IFM_DATE, INS_ID, INS_DATE

	SET NOCOUNT OFF
END






