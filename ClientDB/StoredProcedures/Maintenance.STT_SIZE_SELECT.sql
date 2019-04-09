USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[STT_SIZE_SELECT]
	@TOTAL_ROW		INT = NULL OUTPUT,
	@TOTAL_RESERV	VARCHAR(50) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		@TOTAL_ROW = (SELECT row_count FROM Maintenance.DatabaseSize() WHERE obj_name = 'dbo.ClientStat'),
		@TOTAL_RESERV = dbo.FileByteSizeToStr(SUM(reserved))
	FROM Maintenance.DatabaseSize()
	WHERE obj_name IN
		(
			'dbo.ClientStat'
		)	
END
