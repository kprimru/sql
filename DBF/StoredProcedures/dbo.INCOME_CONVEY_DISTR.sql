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

CREATE PROCEDURE [dbo].[INCOME_CONVEY_DISTR]
	@incomeid INT,
	@distrid INT,
	@incomedate SMALLDATETIME,
	@price MONEY,
	@periodid SMALLINT,
	@prepay BIT,
	@action BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY, ID_ACTION)
		SELECT @incomeid, @distrid, @price, @incomedate, @periodid, @prepay, @action

END







