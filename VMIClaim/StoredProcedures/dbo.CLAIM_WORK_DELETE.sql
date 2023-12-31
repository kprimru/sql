USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_WORK_DELETE]
	@ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.ClaimWork
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_WORK_DELETE] TO rl_write;
GO