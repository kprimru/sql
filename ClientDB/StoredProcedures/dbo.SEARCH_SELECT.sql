USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SEARCH_SELECT]
	@BEGIN	DATETIME = NULL,
	@END	DATETIME = NULL,
	@CATEGORY VARCHAR(50) = NULL,	
	@USER	VARCHAR(50) = NULL,
	@HOST	VARCHAR(50) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF @BEGIN IS NULL
		SET @BEGIN = DATEADD(DAY, -5, GETDATE())

	IF @END IS NULL
		SET @END = GETDATE()

	IF @USER IS NULL
		SET @USER = ORIGINAL_LOGIN()

	IF @HOST IS NULL
		SET @HOST = HOST_NAME()
	
	SELECT MAX(SearchDateTime) AS SearchDateTime, SearchCategory, SearchText
	FROM dbo.SearchTable
	WHERE SearchDateTime >= @BEGIN 
		AND SearchDateTime <= @END
		AND SearchUser = @USER
		AND SearchHost = @HOST
	GROUP BY SearchCategory, SearchText
	ORDER BY SearchDateTime DESC
END