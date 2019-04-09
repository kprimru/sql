USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[SEARCH_SELECT]
	@TYPE	NVARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CNT	INT

	SELECT @CNT = ST_SR_COUNT
	FROM dbo.Settings
	WHERE ST_USER = ORIGINAL_LOGIN()
		AND ST_HOST = HOST_NAME()	

	IF @CNT IS NULL
		SET @CNT = 10

	SELECT TOP (@CNT) CS_ID, CS_SHORT, CS_DATE
	FROM 
		(
			SELECT CS_ID, CS_SHORT, CS_DATE, CS_FREEZE, ROW_NUMBER() OVER(PARTITION BY CS_SHORT ORDER BY CS_DATE DESC) AS RN
			FROM Security.ClientSearch
			WHERE CS_TYPE = @TYPE		
				AND CS_FREEZE = 0
				AND CS_HOST = HOST_NAME()
				AND CS_USER = ORIGINAL_LOGIN()
		) AS o_O 
	WHERE RN = 1
	ORDER BY CS_DATE DESC
END