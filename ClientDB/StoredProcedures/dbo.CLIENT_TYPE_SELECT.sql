USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientTypeID, ClientTypeName, ClientTypeDay, ClientTypeDailyDay, ClientTypePapper
	FROM dbo.ClientTypeTable
	WHERE @FILTER IS NULL
		OR ClientTypeName LIKE @FILTER
	ORDER BY ClientTypeName
END