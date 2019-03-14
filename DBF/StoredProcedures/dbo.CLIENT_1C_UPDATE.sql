USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_1C_UPDATE]
	@OLD_NAME	VARCHAR(50),
	@NEW_NAME	VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientTable
	SET CL_1C = @NEW_NAME
	WHERE CL_1C = @OLD_NAME
END
