USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[TABLE_INDEX_REBUILD]
	@TBL	NVARCHAR(128),
	@IX		NVARCHAR(128),
	@MODE	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL	NVARCHAR(MAX)

	SET @SQL = N'ALTER INDEX [' + @IX + N'] ON ' + @TBL + N' ' + @MODE

	EXEC (@SQL)
END