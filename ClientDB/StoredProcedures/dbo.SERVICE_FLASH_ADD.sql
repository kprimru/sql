USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_FLASH_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_FLASH_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_FLASH_ADD]
	@SERVICEID INT,
    @FLASHID VARCHAR(1023),
	@UN 	VARCHAR(50)
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

		DECLARE @CN INT

		SET @CN = (SELECT COUNT(*) FROM dbo.ServiceFlashTable WHERE ID_FLASH=@FLASHID)

		if (@CN=0)
		INSERT INTO	dbo.ServiceFlashTable(ID_SERVICE, ID_FLASH, UN_FLASH, NUM_COUNT, LAST_DATE)
			VALUES(@SERVICEID, @FLASHID, @UN, 0, GETDATE())
		ELSE
		UPDATE dbo.ServiceFlashTable
		SET ID_SERVICE=@SERVICEID,  NUM_COUNT=0, LAST_DATE = GETDATE()
		WHERE ID_FLASH=@FLASHID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_FLASH_ADD] TO public;
GO
