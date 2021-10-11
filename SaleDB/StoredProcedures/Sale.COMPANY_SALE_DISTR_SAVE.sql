USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_DISTR_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@SYSTEM		UNIQUEIDENTIFIER,
	@NET		UNIQUEIDENTIFIER,
	@COUNT		SMALLINT
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
		INSERT INTO Sale.SaleDistr(ID_SALE, ID_SYSTEM, ID_NET, CNT)
			VALUES(@ID, @SYSTEM, @NET, @COUNT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Sale].[COMPANY_SALE_DISTR_SAVE] TO rl_sale_w;
GO
