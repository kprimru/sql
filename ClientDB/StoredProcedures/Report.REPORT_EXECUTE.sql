USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[REPORT_EXECUTE]
	@ID		UNIQUEIDENTIFIER,
	@PARAM	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SCHEMA NVARCHAR(128)
	DECLARE @PROC	NVARCHAR(128)
	
	SELECT @SCHEMA = REP_SCHEMA, @PROC = REP_PROC
	FROM Report.Reports
	WHERE ID = @ID
	
	IF ISNULL(@SCHEMA, '') = '' OR ISNULL(@PROC, '') = ''
		RETURN
		
	INSERT INTO Report.ExecutionLog(ID_REPORT)
		VALUES(@ID)
		
	DECLARE @SQL NVARCHAR(MAX)
	
	SET @SQL = N'EXEC [' + @SCHEMA + '].[' + @PROC + '] @PARAM'
		
	EXEC sp_executesql @SQL, N'@PARAM NVARCHAR(MAX)', @PARAM
END
