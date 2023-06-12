USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[TAX_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[TAX_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[TAX_LAST]
	@LAST	DATETIME = NULL OUTPUT
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

	SELECT @LAST = MAX(LAST)
	FROM Common.Tax
END

GO
GRANT EXECUTE ON [Common].[TAX_LAST] TO rl_offer_r;
GO
