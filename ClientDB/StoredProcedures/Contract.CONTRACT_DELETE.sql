USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CONTRACT_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CONTRACT_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CONTRACT_DELETE]
	@ID	UNIQUEIDENTIFIER
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

		IF (
				SELECT a.IND
				FROM
					Contract.Status a
					INNER JOIN Contract.Contract b ON a.ID = b.ID_STATUS
				WHERE b.ID = @ID
			) <> 4
		BEGIN
			RAISERROR('Статус договора не позволяет его удалить', 16, 1)
			RETURN
		END

		IF EXISTS
			(
				SELECT *
				FROM Contract.ContractSpecification
				WHERE ID_CONTRACT = @ID
					AND SignDate IS NOT NULL
			)
		BEGIN
			RAISERROR('У договора есть действующие спецификации', 16, 1)
			RETURN
		END;

		IF EXISTS
			(
				SELECT *
				FROM Contract.Additional
				WHERE ID_CONTRACT = @ID
					AND SignDate IS NOT NULL
			)
		BEGIN
			RAISERROR('У договора есть действующие допсоглашения', 16, 1)
			RETURN
		END;

		DELETE FROM Contract.ContractSpecification WHERE ID_CONTRACT = @ID
		DELETE FROM Contract.Additional WHERE ID_CONTRACT = @ID
		DELETE FROM Contract.Contract WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CONTRACT_DELETE] TO rl_contract_register_d;
GO
