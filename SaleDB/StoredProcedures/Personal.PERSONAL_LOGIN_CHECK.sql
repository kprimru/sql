USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_LOGIN_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_LOGIN_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_LOGIN_CHECK]
	@LOGIN		NVARCHAR(128)
WITH EXECUTE AS OWNER
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
		IF LTRIM(RTRIM(@LOGIN)) = N''
			SELECT 'Не введен логин' AS ERROR
		ELSE IF EXISTS(SELECT * FROM sys.server_principals WHERE name = @LOGIN)
			SELECT 'Логин "' + @LOGIN + '" уже присутствует на сервере. Выберите другое имя' AS ERROR
		ELSE IF EXISTS(SELECT * FROM sys.database_principals WHERE name = @LOGIN)
			SELECT 'Пользователь "' + @LOGIN + '" уже присутствует в базе данных. Выберите другое имя' AS ERROR
		ELSE
			SELECT '' AS ERROR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_LOGIN_CHECK] TO rl_personal_r;
GO
