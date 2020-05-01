USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KD_VERSION_INSERT]
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64),
	@ACTIVE	BIT,
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.KDVersion(
				NAME, SHORT, ACTIVE, START, FINISH
			)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@NAME, @SHORT, @ACTIVE, @START, @FINISH)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[KD_VERSION_INSERT] TO rl_kd_version_i;
GO