USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_EMAIL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_EMAIL_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DISTR_EMAIL_SELECT]
	@HostId	Int,
	@Distr	Int,
	@Comp	TinyInt
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

		SELECT DE.[Date], DE.[Email], DE.[UpdUser]
		FROM [dbo].[DistrEmail] AS DE
		WHERE DE.[HostId] = @HostId
			AND DE.[Distr] = @Distr
			AND DE.[Comp] = @Comp
		ORDER BY DE.[Date] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_EMAIL_SELECT] TO rl_distr_email_r;
GO
