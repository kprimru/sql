USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[TABLE_SIZE_SELECT]
	@TOTAL_ROW		BIGINT = NULL OUTPUT,
	@TOTAL_RESERV	VARCHAR(50) = NULL OUTPUT,
	@TOTAL_DATA		VARCHAR(50) = NULL OUTPUT,
	@TOTAL_INDEX	VARCHAR(50) = NULL OUTPUT,
	@TOTAL_UNUSED	VARCHAR(50) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RESERVED_INT	BIGINT

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
			@TOTAL_ROW = SUM(row_count),
			@TOTAL_RESERV = dbo.FileByteSizeToStr(SUM(reserved)),
			@TOTAL_DATA = dbo.FileByteSizeToStr(SUM(data)),
			@TOTAL_INDEX = dbo.FileByteSizeToStr(SUM(index_size)),
			@TOTAL_UNUSED = dbo.FileByteSizeToStr(SUM(unused)),
			@RESERVED_INT = SUM(reserved)
		FROM Maintenance.DatabaseSize()

		SELECT
			obj_name, row_count, reserved_str, data_str, index_str, unused_str,
			ROUND(100 * CONVERT(FLOAT, reserved) / (@RESERVED_INT), 2) AS reserver_percent
		FROM Maintenance.DatabaseSize()
		ORDER BY Reserved DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Maintenance].[TABLE_SIZE_SELECT] TO rl_maintenance;
GO