USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Memo].[KGS_MEMO_SELECT]
	@NAME	NVARCHAR(128),
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@DELETE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF @END IS NOT NULL
		SET @END = DATEADD(DAY, 1, @END)
	
	SELECT 
		ID, NAME, DATE, PRICE,
		(
			SELECT COUNT(*)
			FROM Memo.KGSMemoClient b
			WHERE a.ID = b.ID_MEMO
		) AS CL_COUNT,
		(
			SELECT COUNT(*)
			FROM
				Memo.KGSMemoDistr b
			WHERE a.ID = b.ID_MEMO
		) AS DISTR_COUNT,
		STATUS
	FROM Memo.KGSMemo a
	WHERE (STATUS = 1 OR STATUS = 3 AND @DELETE = 1)
		AND (NAME LIKE @NAME OR @NAME IS NULL)
		AND (DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (DATE < @END OR @END IS NULL)
	ORDER BY DATE DESC, NAME
END
