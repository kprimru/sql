USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_KILL]
	@ID	INT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)
	
	SET @SQL = N'KILL ' + CONVERT(NVARCHAR(16), @ID)
	
	EXEC (@SQL)
END
