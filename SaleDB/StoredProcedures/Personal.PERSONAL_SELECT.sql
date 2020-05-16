USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_SELECT]
	@FILTER		NVARCHAR(256),
	@DISMISS	BIT,
	@RC		INT	= NULL OUTPUT
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
			a.ID,
			ISNULL(a.SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(a.PATRON + ' ', '') AS FULL_NAME,
			a.SHORT, a.SURNAME, a.NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT b.SHORT + ', '
					FROM
						Personal.PersonalType b
						INNER JOIN Personal.OfficePersonalType d ON d.ID_TYPE = b.ID
					WHERE d.ID_PERSONAL = a.ID AND d.EDATE IS NULL
					ORDER BY b.NAME FOR XML PATH('')
				)), 1, 2, '')) AS TP_NAME,
			c.SHORT AS MAN_NAME,
			a.START_DATE, a.END_DATE,
			e.principal_id AS US_ID, f.principal_id AS LG_ID
		FROM
			Personal.OfficePersonal a
			LEFT OUTER JOIN Personal.OfficePersonal c ON a.MANAGER = c.ID
			LEFT OUTER JOIN sys.database_principals e ON e.name = a.login AND e.type IN ('U', 'S')
			LEFT OUTER JOIN sys.server_principals f ON f.name = a.login AND f.type IN ('U', 'S')
		WHERE a.END_DATE IS NULL
			AND
				(
					@FILTER IS NULL
					OR (a.NAME LIKE @FILTER)
					OR (a.SURNAME LIKE @FILTER)
					OR (a.PATRON LIKE @FILTER)
					OR (a.SHORT LIKE @FILTER)
				)

		UNION ALL

		SELECT
			a.ID,
			ISNULL(a.SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(a.PATRON + ' ', '') AS FULL_NAME,
			a.SHORT, a.SURNAME, a.NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT b.NAME + ', '
					FROM
						Personal.PersonalType b
						INNER JOIN Personal.OfficePersonalType d ON d.ID_TYPE = b.ID
					WHERE d.ID_PERSONAL = a.ID AND d.EDATE IS NULL
					ORDER BY b.NAME FOR XML PATH('')
				)), 1, 2, '')) AS TP_NAME,
			c.SHORT AS MAN_NAME,
			a.START_DATE, a.END_DATE,
			e.principal_id AS US_ID, f.principal_id AS LG_ID
		FROM
			Personal.OfficePersonal a
			LEFT OUTER JOIN Personal.OfficePersonal c ON a.MANAGER = c.ID
			LEFT OUTER JOIN sys.database_principals e ON e.name = a.login AND e.type IN ('U', 'S')
			LEFT OUTER JOIN sys.server_principals f ON f.name = a.login AND f.type IN ('U', 'S')
		WHERE a.END_DATE IS NOT NULL AND @DISMISS = 1
			AND
				(
					@FILTER IS NULL
					OR (a.NAME LIKE @FILTER)
					OR (a.SURNAME LIKE @FILTER)
					OR (a.PATRON LIKE @FILTER)
					OR (a.SHORT LIKE @FILTER)
				)
		ORDER BY a.SHORT

		SET @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_SELECT] TO rl_personal_r;
GO