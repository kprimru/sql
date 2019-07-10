USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Описание:		
*/

CREATE PROCEDURE [dbo].[INCOME_EDIT]
	@inid INT,
	@indate SMALLDATETIME,
	@sum MONEY,
	@paydate SMALLDATETIME,
	@paynum VARCHAR(50),
	@primary BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeTable
	SET
		IN_DATE = @indate, 
		IN_SUM = @sum, 
		IN_PAY_DATE = @paydate, 
		IN_PAY_NUM = @paynum,
		IN_PRIMARY = @primary
	WHERE IN_ID = @inid				
END

