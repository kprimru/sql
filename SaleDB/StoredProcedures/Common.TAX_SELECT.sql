USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[TAX_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[TAX_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[TAX_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

	SELECT ID, NAME, CAPTION, RATE, [DEFAULT]
	FROM Common.Tax
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
		OR CAPTION LIKE @FILTER
		OR CONVERT(VARCHAR(50), RATE) LIKE @FILTER
	ORDER BY RATE
END
GO
GRANT EXECUTE ON [Common].[TAX_SELECT] TO rl_offer_r;
GO
