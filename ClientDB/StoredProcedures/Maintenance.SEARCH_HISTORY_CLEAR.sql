USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[SEARCH_HISTORY_CLEAR]
	@DATE	SMALLDATETIME = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF @DATE IS NULL
		TRUNCATE TABLE dbo.ClientSearchFiles
	ELSE
		DELETE 
		FROM dbo.ClientSearchFiles
		WHERE CSF_DATE < @DATE
END
