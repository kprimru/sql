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

CREATE PROCEDURE [dbo].[INCOME_PREPAY_DELETE]	
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.SaldoTable
	WHERE SL_ID_IN_DIS IN
			(
				SELECT ID_ID 
				FROM dbo.IncomeDistrTable
				WHERE ID_PREPAY = 1
			)

	DELETE
	FROM dbo.IncomeDistrTable 
	WHERE ID_PREPAY = 1

END
