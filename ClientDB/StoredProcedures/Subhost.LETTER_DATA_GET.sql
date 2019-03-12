USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[LETTER_DATA_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	
	EXEC [PC275-SQL\GAMMA].Letters.dbo.LETTER_DATA_GET @ID
END
