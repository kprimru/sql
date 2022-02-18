USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_SALE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_SALE_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_SALE_DELETE]
	@ID		UNIQUEIDENTIFIER

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

        DELETE
        FROM dbo.StudySaleRivals
        WHERE StudySale_Id=  @ID

		DELETE
		FROM dbo.StudySale
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SALE_DELETE] TO rl_client_study_d;
GO
