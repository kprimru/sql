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

CREATE PROCEDURE [dbo].[CONSIGNMENT_DETAIL_DELETE]
	@csdid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.SaldoTable
	WHERE SL_ID_CONSIG_DIS = @csdid

	DELETE
	FROM dbo.ConsignmentDetailTable 
	WHERE CSD_ID = @csdid		
END

