USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_VISIT_DELETE]
	@ID			UNIQUEIDENTIFIER
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

		INSERT INTO dbo.ClientStudyVisit(ID_MASTER, ID_CLIENT, ID_TEACHER, DATE, NOTE, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ID_CLIENT, ID_TEACHER, DATE, NOTE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudyVisit
			WHERE ID = @ID

		UPDATE dbo.ClientStudyVisit
		SET	STATUS		=	3,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
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
GRANT EXECUTE ON [dbo].[STUDY_VISIT_DELETE] TO rl_client_study_d;
GO
