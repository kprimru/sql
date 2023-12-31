USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DELETE_BLACKLIST_SYSTEMS_COMMENT]
@COMMENT varchar(300),
@COMMENT_DELETE varchar(300) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.BLACK_LIST_REG
		SET
		COMMENT_DELETE=@COMMENT_DELETE,
		U_LOGIN_DELETE=ORIGINAL_LOGIN(),
		DATE_DELETE=GETDATE(),
		P_DELETE=1
		WHERE [COMPLECTNAME] = @COMMENT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DELETE_BLACKLIST_SYSTEMS_COMMENT] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[DELETE_BLACKLIST_SYSTEMS_COMMENT] TO BL_EDITOR;
GRANT EXECUTE ON [dbo].[DELETE_BLACKLIST_SYSTEMS_COMMENT] TO BL_PARAM;
GRANT EXECUTE ON [dbo].[DELETE_BLACKLIST_SYSTEMS_COMMENT] TO BL_RGT;
GO
