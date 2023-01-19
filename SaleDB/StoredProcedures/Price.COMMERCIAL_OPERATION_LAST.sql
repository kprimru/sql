USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OPERATION_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OPERATION_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OPERATION_LAST]
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
	FROM Price.CommercialOperation
END

GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OPERATION_LAST] TO rl_offer_r;
GO
