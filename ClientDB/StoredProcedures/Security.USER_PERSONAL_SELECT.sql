USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_PERSONAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_PERSONAL_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[USER_PERSONAL_SELECT]
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

		DECLARE @MANAGER	INT
		DECLARE @SERVICE	INT
		DECLARE @DUTY		INT
		DECLARE @TEACHER	INT
		DECLARE @LAWYER		UNIQUEIDENTIFIER

		--IF IS_MEMBER('DBTeacher') = 1 OR IS_MEMBER('DBSuperTeacher') = 1
			SELECT @TEACHER = TeacherID
			FROM dbo.TeacherTable
			WHERE TeacherLogin = ORIGINAL_LOGIN()

		--IF IS_MEMBER('DBDutyService') = 1
			SELECT @DUTY = DutyID
			FROM dbo.DutyTable
			WHERE DutyLogin = ORIGINAL_LOGIN()

		--IF IS_MEMBER('DBService') = 1
			SELECT @SERVICE = ServiceID, @MANAGER = ManagerID
			FROM dbo.ServiceTable
			WHERE ServiceLogin = ORIGINAL_LOGIN()
				AND ServiceDismiss IS NULL

		--IF IS_MEMBER('DBManager') = 1
			SELECT @MANAGER = ManagerID
			FROM dbo.ManagerTable
			WHERE ManagerLogin = ORIGINAL_LOGIN()

		--IF IS_MEMBER('DBLawyer') = 1
			SELECT @LAWYER = LW_ID
			FROM dbo.Lawyer
			WHERE LW_LOGIN = ORIGINAL_LOGIN()

		SELECT
			@SERVICE AS ServiceID,
			@MANAGER AS ManagerID,
			@DUTY AS DutyID,
			@TEACHER AS TeacherID,
			@LAWYER AS LW_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_PERSONAL_SELECT] TO public;
GO
