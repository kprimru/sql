USE [DBF]
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

CREATE PROCEDURE [dbo].[INCOME_CONVEY_FULL]
	@incomeid INT,
	@periodid SMALLINT,
	@incomedate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @clientid INT

	SELECT @clientid = IN_ID_CLIENT 
	FROM dbo.IncomeTable
	WHERE IN_ID = @incomeid

	DECLARE @billid INT

	SELECT @billid = BL_ID
	FROM dbo.BillView
	WHERE BL_ID_CLIENT = @clientid AND PR_ID = @periodid	

	--по каждому дистрибутиву счета нужно вычислить неоплаченную сумму 
	--и ее вычесть из платежа
	
	INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD)
		SELECT @incomeid, DIS_ID, 
			BD_TOTAL_PRICE - 
					ISNULL(
						(
							SELECT SUM(ID_PRICE) 
							FROM 
								dbo.IncomeDistrTable INNER JOIN
								dbo.IncomeTable ON IN_ID = ID_ID_INCOME
							WHERE IN_ID_CLIENT = @clientid
								AND ID_ID_PERIOD = @periodid
								AND ID_ID_DISTR = DIS_ID
						), 0), 
			@incomedate, @periodid
		FROM dbo.BillDistrView
		WHERE BL_ID = @billid 
END







