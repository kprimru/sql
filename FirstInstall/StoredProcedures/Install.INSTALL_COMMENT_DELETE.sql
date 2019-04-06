USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Install].[INSTALL_COMMENT_DELETE]
	@IC_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM
		Install.InstallComments
	WHERE IC_ID = @IC_ID
END
