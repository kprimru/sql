USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[VENDOR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[VENDOR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[VENDOR_SELECT]
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

		SELECT ID, SHORT, FULL_NAME, DIRECTOR
		FROM dbo.Vendor
		WHERE @FILTER IS NULL
			OR FULL_NAME LIKE @FILTER
			OR SHORT LIKE @FILTER
			OR DIRECTOR LIKE @FILTER
		ORDER BY SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[VENDOR_SELECT] TO rl_vendor_r;
GO
