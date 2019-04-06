USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SEARCH_HISTORY_DELETE]
	@CLIENT INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.ClientSearchTable WHERE ClientID = @CLIENT
END