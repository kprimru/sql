USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_GROUP_INSERT]
	@NAME		NVARCHAR(256),
	@CAPTION	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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
		DECLARE @TXT NVARCHAR(MAX)

		IF EXISTS
		(
			SELECT * FROM sys.database_principals WHERE name = @NAME
		)
		BEGIN
			SET @TXT = 'Роль или пользователь "' + @NAME + '" уже существует. Выберите другое название.'

			RAISERROR(@TXT, 16, 1)

			RETURN
		END

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Security.RoleGroup(NAME, CAPTION, NOTE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@NAME, @CAPTION, @NOTE)

		SELECT @ID = ID
		FROM @TBL

		IF ISNULL(@NAME, N'') <> N''
			EXEC ('CREATE ROLE [' + @NAME + ']')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_GROUP_INSERT] TO rl_role_group_w;
GO