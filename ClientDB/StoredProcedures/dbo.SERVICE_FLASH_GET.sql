USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_FLASH_GET]
	@ID_FLASH VARCHAR(1023)
WITH EXECUTE AS OWNER
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

		SELECT	S.ServiceName, UN_FLASH, ID_SERVICE, NUM_COUNT, LAST_DATE FROM dbo.ServiceFlashTable
		LEFT JOIN [dbo].ServiceTable S ON S.ServiceID=ID_SERVICE
		WHERE ID_FLASH = @ID_FLASH

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [dbo].[SERVICE_FLASH_GET] TO public;
GO
