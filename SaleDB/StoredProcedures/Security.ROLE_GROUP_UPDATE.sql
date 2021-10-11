USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_GROUP_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(256),
	@CAPTION	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		DECLARE @OLD_NAME	NVARCHAR(128)

		SELECT @OLD_NAME = NAME
		FROM Security.RoleGroup
		WHERE ID = @ID

		IF (ISNULL(@OLD_NAME, N'') = N'') AND ISNULL(@NAME, N'') <> N''
		BEGIN
			EXEC ('CREATE ROLE [' + @NAME + ']')
		END
		ELSE IF (ISNULL(@OLD_NAME, N'') <> N'') AND ISNULL(@NAME, N'') = N''
		BEGIN
			EXEC ('DROP ROLE [' + @NAME + ']')
		END
		ELSE IF (ISNULL(@OLD_NAME, N'') <> N'') AND (ISNULL(@NAME, N'') <> N'') AND (@OLD_NAME <> @NAME)
		BEGIN
			EXEC ('ALTER ROLE [' + @OLD_NAME + '] WITH NAME = [' + @NAME + ']')
		END

		UPDATE Security.RoleGroup
		SET NAME	= @NAME,
			CAPTION	= @CAPTION,
			NOTE	= @NOTE,
			LAST	= GETDATE()
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_GROUP_UPDATE] TO rl_role_group_w;
GO
