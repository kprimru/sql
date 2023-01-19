USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyDepo@Default]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[CompanyDepo@Default]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[CompanyDepo@Default]
	@Company_Id UniqueIdentifier
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
		SELECT
			[Depo:Region] = '25'
	END TRY
	BEGIN CATCH

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@Default] TO rl_depo_r;
GO
