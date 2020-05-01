USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_HOTLINE_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			a.ID, d.ClientFullName,
			dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS COMPLECT,
			a.FIRST_DATE, a.START, a.FINISH, a.PROFILE, a.FIO, a.EMAIL, a.PHONE, a.CHAT, a.LGN, a.RIC_PERSONAL, a.LINKS,
			DATEDIFF(SECOND, FIRST_DATE, FIRST_ANS) AS FIRST_ANS_SPEED,
			DATEDIFF(SECOND, START, FIRST_ANS) AS SESSION_SPEED
		FROM
			dbo.HotlineChatView a WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
			INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
			INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.CLientID = c.ID_CLIENT
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_HOTLINE_PRINT] TO rl_client_duty_r;
GRANT EXECUTE ON [dbo].[CLIENT_HOTLINE_PRINT] TO rl_expert_distr;
GO