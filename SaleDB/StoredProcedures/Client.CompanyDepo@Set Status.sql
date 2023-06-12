USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyDepo@Set Status]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[CompanyDepo@Set Status]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Status]
	@Id			UniqueIdentifier,
	@Status_Id	SmallInt
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
		UPDATE Client.CompanyDepo
		SET [Status_Id] = @Status_Id
		WHERE [Id] = @Id
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@Set Status] TO rl_depo_status;
GO
