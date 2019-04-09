USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[KGS_MEMO_CLIENT_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID_CLIENT, NAME, ADDRESS, NUM
	FROM 
		Memo.KGSMemoClient a
	WHERE ID_MEMO = @ID
	ORDER BY NUM
END
