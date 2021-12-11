USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERSONAL_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PERSONAL_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PERSONAL_INSERT]
	@DEP	VARCHAR(50),
	@SHORT	VARCHAR(50),
	@FULL	VARCHAR(500),
	@ID		INT = NULL OUTPUT
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

		INSERT INTO dbo.PersonalTable(DepartmentName, PersonalShortName, PersonalFullName)
			VALUES(@DEP, @SHORT, @FULL)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PERSONAL_INSERT] TO rl_personal_other_i;
GO
