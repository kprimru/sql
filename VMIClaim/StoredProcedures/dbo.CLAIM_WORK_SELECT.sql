USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_WORK_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, DATE, NOTE, NUM
	FROM dbo.ClaimWork
	WHERE ID_CLAIM = @ID
	ORDER BY DATE DESC
END
GRANT EXECUTE ON [dbo].[CLAIM_WORK_SELECT] TO rl_read;
GO