USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_NAME]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientFullName AS NAME
	FROM dbo.ClientTable
	WHERE ClientID = @ID
END