USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[TABLE_STAT_UPDATE]
	@TABLE_NAME	NVARCHAR(512)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL	NVARCHAR(MAX)

	SET @SQL = N'UPDATE STATISTICS ' + @TABLE_NAME + N' WITH FULLSCAN'
	EXEC (@SQL)
END