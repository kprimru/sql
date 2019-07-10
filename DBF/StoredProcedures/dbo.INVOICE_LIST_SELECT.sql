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

CREATE PROCEDURE [dbo].[INVOICE_LIST_SELECT]
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@beginnum INT = NULL,
	@endnum INT = NULL
AS
BEGIN
	SET NOCOUNT ON;


	SELECT *
	FROM dbo.InvoiceListView
	WHERE 
		(INS_DATE >= @begindate OR @begindate IS NULL) AND
		(INS_DATE <= @enddate OR @enddate IS NULL)  AND
		(INS_NUM >= @beginnum OR @beginnum IS NULL) AND
		(INS_NUM <= @endnum OR @endnum IS NULL)
	ORDER BY INS_DATE, INS_NUM
END
