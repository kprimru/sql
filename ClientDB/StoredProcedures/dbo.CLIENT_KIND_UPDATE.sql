USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_KIND_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_KIND_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_KIND_UPDATE]
	@Id			SmallInt,
	@Name		VarChar(100),
	@SortIndex	SmallInt
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

		UPDATE dbo.ClientKind
		SET Name		= @Name,
			SortIndex	= @SortIndex
		WHERE Id = @Id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_KIND_UPDATE] TO rl_client_kind_u;
GO
