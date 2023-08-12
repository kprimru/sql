USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contract->Act Sign Period@Insert]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[Contract->Act Sign Period@Insert]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[Contract->Act Sign Period@Insert]
	@Id		SmallInt OUTPUT,
	@Code	VarChar(50),
	@Name	VarChar(100)
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

		INSERT INTO [Contract].[Contracts->Act Sign Periods]([Code], [Name])
		VALUES(@Code, @Name);

		SELECT @Id = Scope_Identity();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[Contract->Act Sign Period@Insert] TO rl_contract_act_sign_period_i;
GO
