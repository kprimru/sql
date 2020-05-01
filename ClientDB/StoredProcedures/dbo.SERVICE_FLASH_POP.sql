USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_FLASH_POP]
    @FLASHID VARCHAR(1023)

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

		UPDATE dbo.ServiceFlashTable
		SET NUM_COUNT = (NUM_COUNT+1), LAST_DATE = GETDATE()
		WHERE ID_FLASH=@FLASHID

		INSERT INTO dbo.ServiceFlashTableCount (ID_FLASH, LAST_DATE) VALUES (@FLASHID, GETDATE())

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SERVICE_FLASH_POP] TO public;
GO