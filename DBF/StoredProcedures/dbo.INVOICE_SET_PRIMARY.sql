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

CREATE PROCEDURE [dbo].[INVOICE_SET_PRIMARY]
	@prpid INT,
	@invoiceid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.PrimaryPayTable
	SET PRP_ID_INVOICE = @invoiceid
	WHERE PRP_ID = @prpid
END
