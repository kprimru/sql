USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_TYPE_WEIGHT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_TYPE_WEIGHT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_TYPE_WEIGHT_SELECT]
	@ACTIVE BIT = 1
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

		SELECT STW_ID, SYS_ID, SYS_SHORT_NAME, SST_ID, SST_CAPTION, STW_WEIGHT
		FROM
			dbo.SystemTypeWeightTable INNER JOIN
			dbo.SystemTable ON STW_ID_SYSTEM = SYS_ID INNER JOIN
			dbo.SystemTypeTable ON STW_ID_TYPE = SST_ID
		WHERE STW_ACTIVE = ISNULL(@ACTIVE, STW_ACTIVE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_WEIGHT_SELECT] TO rl_system_type_weight_r;
GO
