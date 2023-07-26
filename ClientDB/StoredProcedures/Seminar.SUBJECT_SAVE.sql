USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SUBJECT_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SUBJECT_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[SUBJECT_SAVE]
	@ID			UniqueIdentifier OUTPUT,
	@NAME		NVarChar(512),
	@READER		NVarChar(1024),
	@NOTE		NVarChar(MAX),
	@DEMANDS	VarChar(Max) = NULL
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
		SET @DEMANDS = NullIf(@DEMANDS, '');

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
			WHERE ID = @ID;

			DELETE FROM [Seminar].[SubjectDemand] WHERE [Subject_Id] = @Id;
		END;

		INSERT INTO [Seminar].[SubjectDemand]([Subject_Id], [Demand_Id])
		SELECT @ID, Cast(D.[value] AS SmallInt)
		FROM String_Split(@DEMANDS, ',') AS D
		WHERE @DEMANDS IS NOT NULL;

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
