USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[MONTH_SELECT]
	@FILTER		NVARCHAR(128) = NULL,
	@ACTIVE		BIT = 1,
	@RC			INT = NULL OUTPUT
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

	SELECT ID, NAME, DATE, ACTIVE
	FROM Common.Month
	WHERE (ACTIVE = 1 AND @ACTIVE = 1 OR @ACTIVE = 0)
		AND (NAME LIKE @FILTER OR @FILTER IS NULL)
	ORDER BY DATE

	SELECT @RC = @@ROWCOUNT;
END
GO
GRANT EXECUTE ON [Common].[MONTH_SELECT] TO public;
GO