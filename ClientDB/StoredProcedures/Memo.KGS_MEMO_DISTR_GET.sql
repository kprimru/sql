USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[KGS_MEMO_DISTR_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MONTH	UNIQUEIDENTIFIER
	
	SELECT @MONTH = ID_MONTH
	FROM Memo.KGSMemo
	WHERE ID = @ID
		
	SELECT 
		a.ID_CLIENT, a.NUM,
		SystemID, SystemShortName, SystemOrder,
		dbo.DistrString(NULL, DISTR, COMP) AS DISTR_STR,
		DISTR, COMP,
		DistrTypeID, DistrTypeName, DistrTypeOrder,
		SystemTypeID, SystemTypeName,
		DISCOUNT, INFLATION,				
		b.PRICE, b.MON_CNT, b.PRICE, b.TAX_PRICE, b.TOTAL_PRICE, b.TOTAL_PRICE * b.MON_CNT AS TOTAL_PERIOD,
		a.NAME, a.ADDRESS, b.MON_CNT
	FROM 
		Memo.KGSMemoClient a
		INNER JOIN Memo.KGSMemoDistr b ON a.ID_MEMO = b.ID_MEMO AND a.ID_CLIENT = b.ID_CLIENT
		INNER JOIN dbo.SystemTable c ON c.SystemID = b.ID_SYSTEM
		INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = b.ID_NET
		INNER JOIN dbo.SystemTypeTable e ON e.SystemTypeID = b.ID_TYPE		
		INNER JOIN Price.SystemPrice g ON b.ID_SYSTEM = g.ID_SYSTEM
	WHERE a.ID_MEMO = @ID AND g.ID_MONTH = @MONTH AND CURVED = 1
	ORDER BY a.NUM, c.SystemOrder, d.DistrTypeOrder
END
