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

CREATE PROCEDURE [dbo].[INCOME_ACTION_SET]
	@idid INT,
	@action BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeDistrTable
	SET ID_ACTION = @action
	WHERE ID_ID = @idid
END
