USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Kladr].[FIAS_LANDMARK_SELECT]
	@ID	UNIQUEIDENTIFIER,
	@RC	INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = N'EXEC [PC275-SQL\SIGMA].Ric.Fias.LANDMARK_SELECT @ID, @RC OUTPUT'
	
	EXEC sp_executesql @SQL, N'@ID UNIQUEIDENTIFIER, @RC INT OUTPUT', @ID, @RC OUTPUT
END
