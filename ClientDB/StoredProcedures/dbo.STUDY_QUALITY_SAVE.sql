USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_QUALITY_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_QUALITY_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_QUALITY_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@TEACHER	INT,
	@NOTE		NVARCHAR(MAX),
	@TYPE		UNIQUEIDENTIFIER,
	@WEIGHT		DECIMAL(8, 4),
	@SYS_LIST	NVARCHAR(MAX)
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
			INSERT INTO dbo.StudyQuality(ID_CLIENT, DATE, NOTE, ID_TEACHER, ID_TYPE, WEIGHT, SYS_LIST)
				VALUES(@CLIENT, @DATE, @NOTE, @TEACHER, @TYPE, @WEIGHT, @SYS_LIST)
		ELSE
			UPDATE dbo.StudyQuality
			SET	DATE		=	@DATE,
				ID_TEACHER	=	@TEACHER,
				NOTE		=	@NOTE,
				ID_TYPE		=	@TYPE,
				WEIGHT		=	@WEIGHT,
				SYS_LIST	=	@SYS_LIST
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
GRANT EXECUTE ON [dbo].[STUDY_QUALITY_SAVE] TO rl_client_study_u;
GO
