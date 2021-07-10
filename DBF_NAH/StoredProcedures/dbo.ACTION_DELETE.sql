USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACTION_DELETE]
	@ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.ActionPeriod
	WHERE AP_ID_AC = @ID

	DELETE
	FROM dbo.Action
	WHERE ACTN_ID = @ID
END

GO
GRANT EXECUTE ON [dbo].[ACTION_DELETE] TO rl_action_d;
GO