USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[INET_CONTROL_UNSET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[INET_CONTROL_UNSET]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[INET_CONTROL_UNSET]
	@UD_ID	UNIQUEIDENTIFIER
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

		UPDATE USR.InetControl
		SET IC_RDATE = GETDATE(),
			IC_RUSER = ORIGINAL_LOGIN()
		WHERE IC_ID_COMPLECT = @UD_ID AND IC_RDATE IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[INET_CONTROL_UNSET] TO DBChief;
GRANT EXECUTE ON [USR].[INET_CONTROL_UNSET] TO DBQuality;
GRANT EXECUTE ON [USR].[INET_CONTROL_UNSET] TO DBTech;
GO
