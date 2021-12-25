USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CREATE_USER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CREATE_USER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CREATE_USER]
        @login varchar(50),
    @password varchar(50)
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

		EXEC('CREATE LOGIN ' + @login + ' WITH PASSWORD = ''' + @password + ''', CHECK_POLICY = OFF ')

		EXEC('CREATE USER ' + @login + ' FOR LOGIN ' + @login)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CREATE_USER] TO DBChief;
GRANT EXECUTE ON [dbo].[CREATE_USER] TO DBTech;
GO
