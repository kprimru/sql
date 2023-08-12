USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERSONAL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PERSONAL_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[PERSONAL_GET]
	@ID	INT
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

		SELECT PersonalID, DepartmentName, PersonalShortName, PersonalFullName
		FROM dbo.PersonalTable
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
GRANT EXECUTE ON [dbo].[PERSONAL_GET] TO rl_personal_other_d;
GRANT EXECUTE ON [dbo].[PERSONAL_GET] TO rl_personal_other_r;
GO
