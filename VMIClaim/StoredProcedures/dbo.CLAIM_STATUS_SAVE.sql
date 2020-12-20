USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_STATUS_SAVE]
	@CLAIM		UNIQUEIDENTIFIER,
	@STATUS	    UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.Claim
	SET ID_STATUS	=	@STATUS
	WHERE ID = @CLAIM
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_STATUS_SAVE] TO rl_write;
GO