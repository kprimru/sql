USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BL_GET_ROLES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BL_GET_ROLES]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[BL_GET_ROLES]
	@User varchar(128) OUTPUT,
	@db_role int = 0 OUTPUT
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

		SET @db_role = 0; --Неизвестная роль
		SET @User = ORIGINAL_LOGIN()
		if (IS_MEMBER('db_owner')=1) SET @db_role = 1023; else
		BEGIN
		if (IS_MEMBER('BL_READER')=1) SET @db_role = @db_role+1;
		if (IS_MEMBER('BL_EDITOR')=1) SET @db_role = @db_role+2;
		if (IS_MEMBER('BL_RGT')=1) SET @db_role = @db_role+4;
		if (IS_MEMBER('BL_PARAM')=1) SET @db_role = @db_role+8;
		if (IS_MEMBER('BL_ADMIN')=1) SET @db_role = @db_role+16;
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
GRANT EXECUTE ON [dbo].[BL_GET_ROLES] TO public;
GO
