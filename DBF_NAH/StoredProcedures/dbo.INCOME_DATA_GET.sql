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

ALTER PROCEDURE [dbo].[INCOME_DATA_GET]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		IN_ID, CL_ID, CL_FULL_NAME, IN_DATE, IN_PAY_DATE, IN_SUM, IN_PAY_NUM,
		IN_SUM -
			ISNULL
				(
					(
						SELECT SUM(ID_PRICE)
						FROM dbo.IncomeDistrTable
						WHERE ID_ID_INCOME = IN_ID
					), 0
				) AS IN_REST
	FROM
		dbo.IncomeTable a INNER JOIN
		dbo.ClientTable b ON a.IN_ID_CLIENT = b.CL_ID
	WHERE IN_ID = @incomeid
END



GO
GRANT EXECUTE ON [dbo].[INCOME_DATA_GET] TO rl_income_r;
GO