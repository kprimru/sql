USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[USER_ROLES_SELECT]
	@USER	VARCHAR(50)
WITH EXECUTE AS OWNER
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

		SELECT 
			RoleID, RoleMasterID, RoleName, RoleCaption, RoleNote,
			CONVERT(BIT, CASE
				WHEN RL_DIRECT IS NULL THEN 0
				WHEN RL_DIRECT = 1 THEN 1
				WHEN RL_DIRECT = 0 THEN NULL
				ELSE 0
			END) AS RoleSelect,
			CONVERT(BIT, CASE
				WHEN RL_DIRECT IS NULL THEN 0
				WHEN RL_DIRECT = 1 THEN 1
				WHEN RL_DIRECT = 0 THEN NULL
				ELSE 0
			END) AS RoleSelectData
		FROM	
			Security.Roles 
			LEFT OUTER JOIN Security.RoleUserView ON RL_NAME = RoleName AND US_NAME = @USER
		ORDER BY RoleCaption
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END