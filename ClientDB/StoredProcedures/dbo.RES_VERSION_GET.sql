USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RES_VERSION_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ResVersionNumber, IsLatest, ResVersionBegin, ResVersionEnd
	FROM dbo.ResVersionTable
	WHERE ResVersionID = @ID
END