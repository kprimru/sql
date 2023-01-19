USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyDepo@Set Status?Accept]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[CompanyDepo@Set Status?Accept]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Status?Accept]
	@Id		UniqueIdentifier
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

	DECLARE
		@GUIds					VarChar(Max),
		@Status_Id_ACCEPT		SmallInt,
		@Status_Id_NEW			SmallInt;

	BEGIN TRY
		SET @GUIds =
			(
				SELECT
					[@id] = @Id
				FOR XML PATH('item'), ROOT('root')
			);

		SET @Status_Id_ACCEPT		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACCEPT');
		SET @Status_Id_NEW			= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'NEW');

		IF (SELECT TOP (1) [Status_Id] FROM [Client].[CompanyDepo] WHERE [Id] = @Id) = @Status_Id_NEW
			EXEC [Client].[CompanyDepo@Set Status(Internal)] @GUIds = @GUIds, @Status_Id = @Status_Id_ACCEPT;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@Set Status?Accept] TO rl_depo_w;
GO
