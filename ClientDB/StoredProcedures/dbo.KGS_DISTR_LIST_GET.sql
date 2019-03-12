USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[KGS_DISTR_LIST_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT KDL_NAME
	FROM dbo.KGSDistrList
	WHERE KDL_ID = @ID
END