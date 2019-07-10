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

CREATE PROCEDURE [dbo].[CONSIGNMENT_DELETE]
	@csgid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.SaldoTable
	WHERE SL_ID_CONSIG_DIS IN
			(
				SELECT CSD_ID
				FROM dbo.ConsignmentDetailTable
				WHERE CSD_ID_CONS = @csgid
			)

	DELETE 
	FROM dbo.ConsignmentDetailTable
	WHERE CSD_ID_CONS = @csgid

	DELETE
	FROM dbo.ConsignmentTable
	WHERE CSG_ID = @csgid
END


