USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[USR_SIZE_SELECT]
	@TOTAL_ROW		BIGINT = NULL OUTPUT,
	@TOTAL_RESERV	VARCHAR(50) = NULL OUTPUT
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

		SELECT
			@TOTAL_ROW = (SELECT row_count FROM Maintenance.DatabaseSize() WHERE obj_name = 'USR.USRFile'),
			@TOTAL_RESERV = dbo.FileByteSizeToStr(SUM(reserved))
		FROM Maintenance.DatabaseSize()
		WHERE obj_name IN
			(
				'USR.USRUpdates',
				'USR.USRFile',
				'USR.USRIB',
				'USR.USRIBDateView',
				'USR.USRPackage',
				'USR.USRComplianceView',
				'USR.USRFileView',
				'USR.USRIBComplianceView',
				'USR.USRData',
				'USR.USRVersionView',
				'USR.USRComplectCurrentStatusView'
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Maintenance].[USR_SIZE_SELECT] TO rl_maintenance;
GO