USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_FINANCING_GET]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM dbo.ClientFinancing
	WHERE ID_CLIENT = @ID
END
