USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_PASSWORD]
	@ID		UNIQUEIDENTIFIER,
	@LOGIN	NVARCHAR(128),
	@PASS	NVARCHAR(128)
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

		IF @LOGIN IS NULL
			SELECT @LOGIN = LOGIN
			FROM Personal.OfficePersonal
			WHERE ID = @ID

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER LOGIN ' + QUOTENAME(@LOGIN) + ' WITH PASSWORD = ' + QUOTENAME(@PASS, '''')
		EXEC (@SQL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_PASSWORD] TO rl_user_w;
GO