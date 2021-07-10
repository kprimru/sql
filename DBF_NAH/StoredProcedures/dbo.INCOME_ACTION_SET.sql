USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[INCOME_ACTION_SET]
	@idid INT,
	@action BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeDistrTable
	SET ID_ACTION = @action
	WHERE ID_ID = @idid
END

GO
GRANT EXECUTE ON [dbo].[INCOME_ACTION_SET] TO rl_income_w;
GO