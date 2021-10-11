USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USER_CREATE]
	@US_NAME	NVARCHAR(128)
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

	    IF NOT EXISTS
		    (
			    SELECT *
			    FROM sys.server_principals
			    WHERE [name] = @US_NAME
				    AND [type] = 'U'
		    )
	    BEGIN
		    EXEC('CREATE LOGIN [' + @US_NAME + '] FROM WINDOWS')
	    END

	    IF EXISTS
		    (
			    SELECT *
			    FROM sys.server_principals
			    WHERE [name] = @US_NAME
				    AND [type] = 'U'
		    )
	    BEGIN
		    EXEC('CREATE USER [' + @US_NAME + '] FOR LOGIN [' + @US_NAME + ']')

		    EXEC sp_addrolemember 'rl_common', @US_NAME
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
GRANT EXECUTE ON [dbo].[USER_CREATE] TO rl_admin;
GO
