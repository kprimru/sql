USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_TYPE_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CPT_NAME, CPT_PSEDO, CPT_REQUIRED
	FROM dbo.ClientPersonalType
	WHERE CPT_ID = @ID
END