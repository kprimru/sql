USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[ROLES_SELECT]
	@SH_ID	UNIQUEIDENTIFIER,
	@LGN	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
	DECLARE @R NVARCHAR(MAX)
	
	SELECT @R = ROLES
	FROM Subhost.Users
	WHERE ID_SUBHOST = @SH_ID AND NAME = @LGN

	SET @XML = CAST(@R AS XML)

	SELECT c.value('(@name)', 'NVARCHAR(128)') AS RL_NAME
	FROM @XML.nodes('/root/role') a(c)	
END
