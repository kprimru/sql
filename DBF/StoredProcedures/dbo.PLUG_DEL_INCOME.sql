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

CREATE PROCEDURE [dbo].[PLUG_DEL_INCOME]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeTable
	SET IN_ID_INVOICE = NULL		
	WHERE IN_ID = @incomeid
END
