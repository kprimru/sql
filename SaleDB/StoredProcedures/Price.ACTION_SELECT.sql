USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[ACTION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[ACTION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[ACTION_SELECT]
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

	SELECT ID, NAME, DELIVERY, SUPPORT, DELIVERY_FIXED
	FROM Price.Action
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
	ORDER BY NAME
END

GO
GRANT EXECUTE ON [Price].[ACTION_SELECT] TO rl_office_r;
GO
