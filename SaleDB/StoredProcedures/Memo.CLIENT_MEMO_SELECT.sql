USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[CLIENT_MEMO_SELECT]
	@CLIENT	UNIQUEIDENTIFIER,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, Common.DateOf(a.DATE) AS DATE, c.SHORT, b.NAME AS SER_NAME, 
		d.NAME AS DOC_NAME, START, FINISH, PayTypeName AS ContractPayName,
		SYSTEMS,
		a.MONTH_PRICE, a.PERIOD_PRICE
	FROM 
		Memo.ClientMemo a
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.Service b ON a.ID_SERVICE = b.ID
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.Vendor c ON a.ID_VENDOR = c.ID
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.Document d ON a.ID_DOC_TYPE = d.ID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.PayTypeTable e ON a.ID_PAY_TYPE = e.PayTypeID
	WHERE a.ID_CLIENT = @CLIENT
	ORDER BY DATE DESC
	
	SELECT @RC = @@ROWCOUNT
END
