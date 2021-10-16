USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Raw].[Incomes@Get Metadata Captions]
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

        SELECT [Code], [Caption]
        FROM [Raw].[Incomes:Import?Metadata]

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Incomes@Get Metadata Captions] TO rl_income_w;
GO
