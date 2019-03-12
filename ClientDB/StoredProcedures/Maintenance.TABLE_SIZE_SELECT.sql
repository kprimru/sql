USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[TABLE_SIZE_SELECT]
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
END