USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OPERATION_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
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

	SELECT ID, NAME
	FROM Price.CommercialOperation
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
	ORDER BY NAME
END

GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OPERATION_SELECT] TO rl_offer_r;
GO
