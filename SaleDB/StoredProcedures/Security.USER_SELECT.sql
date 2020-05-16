USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_SELECT]
	@FILTER	NVARCHAR(256) = NULL
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
			a.ID, a.LOGIN, a.NAME,
			REVERSE(STUFF(REVERSE((
				SELECT CAPTION + ', '
				FROM
					Security.RoleGroup c
					INNER JOIN sys.database_principals d ON c.NAME = d.NAME
					INNER JOIN sys.database_role_members e ON e.role_principal_id = d.principal_id
					INNER JOIN sys.database_principals f ON e.member_principal_id = f.principal_id
				WHERE f.NAME = a.LOGIN
				ORDER BY CAPTION FOR XML PATH('')
			)), 1, 2, '')) AS GROUPS
		FROM
			Security.Users a
			LEFT OUTER JOIN sys.database_principals b ON a.LOGIN = b.NAME
		WHERE a.STATUS = 1
			AND
				(
					@FILTER IS NULL
					OR a.LOGIN LIKE @FILTER
					OR a.NAME LIKE @FILTER
				)
		ORDER BY a.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_SELECT] TO rl_user_r;
GO