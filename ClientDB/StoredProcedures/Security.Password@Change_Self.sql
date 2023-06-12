USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[Password@Change?Self]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[Password@Change?Self]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[Password@Change?Self]
	@OldPass	NVarChar(128),
	@NewPass	NVarChar(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Sql			NVarChar(Max),
		@User			NVarChar(128) = Original_Login();

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @SQL = 'ALTER LOGIN [' + @User + '] WITH PASSWORD = ''' + @NewPass + ''' OLD_PASSWORD = ''' + @OldPass + ''', CHECK_POLICY = OFF';
		PRINT(@SQL);

		EXEC (@SQL);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[Password@Change?Self] TO public;
GO
