USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERSONAL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PERSONAL_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[PERSONAL_UPDATE]
	@ID		INT,
	@DEP	VARCHAR(50),
	@SHORT	VARCHAR(50),
	@FULL	VARCHAR(500)
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

		UPDATE dbo.PersonalTable
		SET DepartmentName = @DEP,
			PersonalShortName = @SHORT,
			PersonalFullName = @FULL
		WHERE PersonalID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PERSONAL_UPDATE] TO rl_personal_other_u;
GO
