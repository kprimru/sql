USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Status?Termination]
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
		@Status_Id_ACTIVE		SmallInt,
		@Status_Id_TERMINATION	SmallInt;

	BEGIN TRY
		SET @GUIds =
			(
				SELECT
					[@id] = @Id
				FOR XML PATH('item'), ROOT('root')
			);

		SET @Status_Id_ACTIVE		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACTIVE');
		SET @Status_Id_TERMINATION	= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'TERMINATION');

		IF (SELECT TOP (1) [Status_Id] FROM [Client].[CompanyDepo] WHERE [Id] = @Id) != @Status_Id_ACTIVE
			RaisError('Из текущего статуса невозможно перевести в "На исключение"', 16, 1);

		EXEC [Client].[CompanyDepo@Set Status(Internal)] @GUIds = @GUIds, @Status_Id = @Status_Id_TERMINATION;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@Set Status?Termination] TO rl_depo_w;
GO