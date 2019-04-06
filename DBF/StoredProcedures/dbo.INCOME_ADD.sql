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

CREATE PROCEDURE [dbo].[INCOME_ADD]
	@clientid INT,
	@indate SMALLDATETIME,
	@sum MONEY,
	@paydate SMALLDATETIME,
	@paynum VARCHAR(50),
	@primary BIT = 0,
	@returnvalue BIT = 1

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @orgid SMALLINT

	SELECT @orgid = CL_ID_ORG
	FROM dbo.ClientTable 
	WHERE CL_ID = @clientid

	INSERT INTO dbo.IncomeTable
		(
			IN_ID_CLIENT, IN_DATE, IN_SUM, IN_PAY_DATE, 
			IN_PAY_NUM, IN_ID_ORG, IN_PRIMARY
		)
	VALUES
		(
			@clientid, @indate, @sum, @paydate, @paynum, @orgid, @primary
		)	
	
	IF @returnvalue = 1 
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END









