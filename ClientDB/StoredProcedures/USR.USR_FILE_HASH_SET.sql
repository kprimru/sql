USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[USR_FILE_HASH_SET]
	@ID		UNIQUEIDENTIFIER,
	--@ID		INT,
	@HASH	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	
	UPDATE USR.USRFile
	SET UF_HASH = @HASH
	WHERE UF_HASH IS NULL
		AND UF_ID = @ID;
	
	
	--EXEC [PC275-SQL\OMEGA].[IPLogs].[dbo].[USR_FILE_HASH_SET] @ID, @HASH;
END