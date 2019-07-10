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

CREATE PROCEDURE [dbo].[CONSIGNMENT_CHECK_INVOICE]
	@consid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CSG_DATE, CSG_ID
	FROM dbo.ConsignmentTable
	WHERE CSG_ID_INVOICE IS NOT NULL AND CSG_ID = @consid AND
		(
			SELECT INS_RESERVE
			FROM dbo.InvoiceSaleTable
			WHERE INS_ID = CSG_ID_INVOICE
		) = 0
END



