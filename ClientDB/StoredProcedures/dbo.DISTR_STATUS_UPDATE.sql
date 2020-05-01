USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_STATUS_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(64),
	@REG	TINYINT,
	@IMAGE	VARBINARY(MAX),
	@INDEX	TINYINT
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

		UPDATE dbo.DistrStatus
		SET DS_NAME = @NAME,
			DS_REG = @REG,
			DS_IMAGE = @IMAGE,
			DS_INDEX = @INDEX
		WHERE DS_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DISTR_STATUS_UPDATE] TO rl_distr_status_u;
GO