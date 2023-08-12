USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_MEMBER_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_MEMBER_SET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[ROLE_MEMBER_SET]
	@ROLE	NVARCHAR(128),
	@MEMBER	NVARCHAR(128),
	@MODE	BIT
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

		IF @MODE = 1
			EXEC sp_droprolemember @ROLE, @MEMBER
		ELSE IF @MODE = 0
			EXEC sp_addrolemember @ROLE, @MEMBER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_MEMBER_SET] TO rl_user_roles;
GO
