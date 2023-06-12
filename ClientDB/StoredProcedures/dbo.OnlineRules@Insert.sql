USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[OnlineRules@Insert]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[OnlineRules@Insert]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[OnlineRules@Insert]
	@System_Id		Int,
	@DistrType_Id	Int,
	@Quantity		SmallInt
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

		INSERT INTO [dbo].[OnlineRules]([System_Id], [DistrType_Id], [Quantity])
		VALUES(@System_Id, @DistrType_Id, @Quantity);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[OnlineRules@Insert] TO rl_online_rules_i;
GO
