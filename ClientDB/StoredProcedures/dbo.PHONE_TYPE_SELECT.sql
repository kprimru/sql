USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PHONE_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PHONE_TYPE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PHONE_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT PT_ID, PT_NAME, PT_SHORT
		FROM dbo.PhoneType
		WHERE @FILTER IS NULL
			OR PT_NAME LIKE @FILTER
			OR PT_SHORT LIKE @FILTER
		ORDER BY PT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PHONE_TYPE_SELECT] TO rl_phone_type_r;
GO
