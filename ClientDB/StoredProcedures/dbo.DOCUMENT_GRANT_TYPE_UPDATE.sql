USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DOCUMENT_GRANT_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(50),
	@DEF	BIT
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

		IF @DEF = 1
			UPDATE dbo.DocumentGrantType
			SET DEF = 0
			WHERE ID <> @ID

		UPDATE	dbo.DocumentGrantType
		SET		NAME	=	@NAME,
				DEF		=	@DEF
		WHERE	ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DOCUMENT_GRANT_TYPE_UPDATE] TO rl_doc_grant_type_u;
GO