USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_DELETE]
	@inid INT

AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.SaldoTable
	WHERE SL_ID_IN_DIS IN
			(
				SELECT ID_ID
				FROM dbo.IncomeDistrTable
				WHERE ID_ID_INCOME = @inid
			)

	DELETE
	FROM dbo.IncomeDistrTable
	WHERE ID_ID_INCOME = @inid

	DELETE
	FROM dbo.IncomeTable
	WHERE IN_ID = @inid
END




GO
GRANT EXECUTE ON [dbo].[INCOME_DELETE] TO rl_income_d;
GO