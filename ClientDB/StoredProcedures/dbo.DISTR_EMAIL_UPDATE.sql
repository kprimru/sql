USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_EMAIL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_EMAIL_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DISTR_EMAIL_UPDATE]
	@HostId	Int,
	@Distr	Int,
	@Comp	TinyInt,
	@Email	VarChar(128)
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

		INSERT INTO [dbo].[DistrEmail]([HostId], [Distr], [Comp], [Date], [Email])
		SELECT @HostId, @Distr, @Comp, GetDate(), @Email;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_EMAIL_UPDATE] TO rl_distr_email_u;
GO
