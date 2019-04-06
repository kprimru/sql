USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VENDOR_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SHORT, FULL_NAME, DIRECTOR
	FROM dbo.Vendor
	WHERE ID = @ID
END