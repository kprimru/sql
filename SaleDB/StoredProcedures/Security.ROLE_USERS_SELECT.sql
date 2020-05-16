USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_USERS_SELECT]
	@ROLE	NVARCHAR(128)
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
		SELECT
			0 AS TP, CAPTION, NAME,
			CONVERT(BIT, ISNULL((
				SELECT COUNT(*)
				FROM
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
					INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
				WHERE a.NAME = @ROLE AND c.NAME = z.NAME
			), 0)) AS CHECKED
		FROM Security.RoleGroup z

		UNION ALL

		SELECT
			1 AS TP, NAME, LOGIN,
			CONVERT(BIT, ISNULL((
				SELECT COUNT(*)
				FROM
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
					INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
				WHERE a.NAME = @ROLE AND c.NAME = z.LOGIN
			), 0))
		FROM Security.Users z
		WHERE z.STATUS = 1

		ORDER BY TP, CAPTION

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_USERS_SELECT] TO rl_user_role_r;
GO