USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NAMED_SET_UPDATE]
	@SET_NAME	NVARCHAR(128),
	@REF_NAME	NVARCHAR(128),
	@VALUES		NVARCHAR(MAX)
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

		DECLARE @ID	UNIQUEIDENTIFIER

		SELECT @ID = SetId
		FROM dbo.NamedSets
		WHERE SetName=@SET_NAME AND RefName=@REF_NAME

		DELETE FROM dbo.NamedSetsItems
		WHERE SetId=@ID

		DELETE FROM dbo.NamedSets
		WHERE SetName=@SET_NAME AND RefName=@REF_NAME

		EXEC dbo.NAMED_SET_ADD @SET_NAME, @REF_NAME, @VALUES

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[NAMED_SET_UPDATE] TO rl_named_sets_u;
GO