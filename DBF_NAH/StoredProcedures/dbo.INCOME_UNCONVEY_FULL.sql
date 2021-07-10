USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[INCOME_UNCONVEY_FULL]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.SaldoTable
	WHERE SL_ID_IN_DIS IN (SELECT ID_ID FROM dbo.IncomeDistrTable WHERE ID_ID_INCOME = @incomeid)

	DELETE FROM dbo.IncomeDistrTable
	WHERE ID_ID_INCOME = @incomeid
END
GO
GRANT EXECUTE ON [dbo].[INCOME_UNCONVEY_FULL] TO rl_income_w;
GO