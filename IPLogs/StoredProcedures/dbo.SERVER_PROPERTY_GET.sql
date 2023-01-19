USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVER_PROPERTY_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVER_PROPERTY_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVER_PROPERTY_GET]
	@SERVER	INT,
	@NAME	VARCHAR(50),
	@VALUE	NVARCHAR(512) OUTPUT
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

	    IF @NAME = 'SERVER_PATH'
		    SELECT @VALUE = SRV_PATH
		    FROM dbo.Servers
		    WHERE SRV_ID = @SERVER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVER_PROPERTY_GET] TO rl_common;
GO
