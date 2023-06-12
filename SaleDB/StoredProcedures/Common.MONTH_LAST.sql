USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[MONTH_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[MONTH_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[MONTH_LAST]
	@LAST	DATETIME OUTPUT
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

	BEGIN TRY
		SELECT	@LAST = MAX(LAST)
		FROM	Common.Month

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Common].[MONTH_LAST] TO public;
GRANT EXECUTE ON [Common].[MONTH_LAST] TO rl_month_r;
GO
