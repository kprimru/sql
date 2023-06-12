USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_FOUNDATION_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_FOUNDATION_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTRACT_FOUNDATION_SAVE]
	@ID	UNIQUEIDENTIFIER OUTPUT,
	@NAME	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO dbo.ContractFoundation(NAME)
				OUTPUT inserted.ID INTO @TBL
				VALUES (@NAME)

			SELECT @ID = ID
			FROM @TBL
		END
		ELSE
			UPDATE dbo.ContractFoundation
			SET NAME = @NAME,
				LAST = GETDATE()
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_FOUNDATION_SAVE] TO rl_contract_foundation_u;
GO
