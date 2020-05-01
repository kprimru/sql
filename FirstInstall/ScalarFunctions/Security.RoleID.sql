USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Security].[RoleID]
(
	@RL_ROLE VARCHAR(128)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @ID UNIQUEIDENTIFIER

	SELECT @ID = RL_ID
	FROM Security.Roles
	WHERE RL_ROLE = @RL_ROLE

	RETURN @ID
END
