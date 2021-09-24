USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CONTRACT_PAY_SELECT]
	@FILTER	NVARCHAR(256),
	@RC		INT	= NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	EXEC [PC275-SQL\ALPHA].ClientDB.dbo.CONTRACT_PAY_SELECT
END

GO
GRANT EXECUTE ON [Memo].[CONTRACT_PAY_SELECT] TO rl_client_memo_ref;
GO
