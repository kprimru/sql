USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[USR_SIZE_SELECT]
	@TOTAL_ROW		BIGINT = NULL OUTPUT,
	@TOTAL_RESERV	VARCHAR(50) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

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
END