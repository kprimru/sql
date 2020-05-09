USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_VISIT_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@TEACHER	INT,
	@DATE		SMALLDATETIME,
	@NOTE		NVARCHAR(MAX)
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

		IF @ID IS NULL
			INSERT INTO dbo.ClientStudyVisit(ID_CLIENT, ID_TEACHER, DATE, NOTE)
				VALUES(@CLIENT, @TEACHER, @DATE, @NOTE)
		ELSE
		BEGIN
			INSERT INTO dbo.ClientStudyVisit(ID_MASTER, ID_CLIENT, ID_TEACHER, DATE, NOTE, STATUS, UPD_DATE, UPD_USER)
				SELECT @ID, ID_CLIENT, ID_TEACHER, DATE, NOTE, 2, UPD_DATE, UPD_USER
				FROM dbo.ClientStudyVisit
				WHERE ID = @ID

			UPDATE dbo.ClientStudyVisit
			SET	ID_TEACHER	=	@TEACHER,
				DATE		=	@DATE,
				NOTE		=	@NOTE,
				UPD_DATE	=	GETDATE(),
				UPD_USER	=	ORIGINAL_LOGIN()
			WHERE ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_VISIT_SAVE] TO rl_client_study_u;
GO