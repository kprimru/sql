USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contract->Act Sign Period@Get]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[Contract->Act Sign Period@Get]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[Contract->Act Sign Period@Get]
	@Id  SmallInt
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

		SELECT [Name], [Code]
		FROM [Contract].[Contracts->Act Sign Periods]
		WHERE [Id] = @Id;


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[Contract->Act Sign Period@Get] TO rl_contract_act_sign_period_r;
GO
