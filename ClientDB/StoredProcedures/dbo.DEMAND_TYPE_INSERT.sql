USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DEMAND_TYPE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DEMAND_TYPE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DEMAND_TYPE_INSERT]
	@NAME			VARCHAR(100),
	@CODE			VARCHAR(100),
	@SORT_INDEX		SMALLINT,
	@ID				INT = NULL OUTPUT
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

		INSERT INTO [dbo].[Demand->Type]([Name], [Code], [SortIndex])
			VALUES(@NAME, @CODE, @SORT_INDEX)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DEMAND_TYPE_INSERT] TO rl_demand_type_i;
GO
