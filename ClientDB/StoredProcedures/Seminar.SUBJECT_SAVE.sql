USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SUBJECT_SAVE]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@NAME	NVARCHAR(512),
	@READER	NVARCHAR(1024),
	@NOTE	NVARCHAR(MAX)
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

		SET @NAME = Replace(Replace(@Name, Char(10), ''), Char(13), '');

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO Seminar.Subject(NAME, NOTE, READER)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@NAME, @NOTE, @READER)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Seminar.Subject
			SET NAME	=	@NAME,
				NOTE	=	@NOTE,
				READER	=	@READER
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
GRANT EXECUTE ON [Seminar].[SUBJECT_SAVE] TO rl_seminar_admin;
GO