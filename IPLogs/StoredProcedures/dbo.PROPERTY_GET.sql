USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[PROPERTY_GET]
	@NAME	NVARCHAR(64),
	@VALUE	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @VALUE = ST_VALUE
	FROM dbo.Settings
	WHERE ST_NAME = @NAME
END
