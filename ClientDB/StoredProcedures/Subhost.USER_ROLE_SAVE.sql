USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[USER_ROLE_SAVE]
	@SH		UNIQUEIDENTIFIER,
	@USER	UNIQUEIDENTIFIER,
	@ROLES	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Subhost.Users
	SET ROLES = @ROLES
	WHERE ID_SUBHOST = @SH
		AND ID = @USER
END
