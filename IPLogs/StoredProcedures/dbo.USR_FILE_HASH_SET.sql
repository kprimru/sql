USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USR_FILE_HASH_SET]
	--@ID		UNIQUEIDENTIFIER,
	@ID		INT,
	@HASH	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	/*
	UPDATE USR.USRFile
	SET UF_HASH = @HASH
	WHERE UF_HASH IS NULL
		AND UF_ID = @ID;
	*/

	UPDATE dbo.USRFiles
	SET UF_MD5 = @HASH
	WHERE UF_MD5 IS NULL
		AND UF_ID = @ID
END
