USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[OnlineRules@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[OnlineRules@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[OnlineRules@Select]
	@Filter	VarChar(Max) = NULL
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

		SELECT [System_Id], [DistrType_Id], [Quantity]
		FROM [dbo].[OnlineRules];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[OnlineRules@Select] TO rl_online_rules_r;
GO
