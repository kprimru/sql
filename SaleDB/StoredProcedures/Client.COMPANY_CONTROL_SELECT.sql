USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CONTROL_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@DEL	BIT,
	@RC		INT = NULL OUTPUT
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
			a.ID, a.DATE, a.NOTIFY_DATE, a.REMOVE_DATE, a.REMOVE_USER, a.NOTE, a.STATUS,
			ISNULL(
			    (
			        SELECT TOP 1 SHORT
			        FROM Personal.OfficePersonal
			        WHERE LOGIN = a.UPD_USER
			            AND [END_DATE] IS NULL
			        ), a.UPD_USER
			    ) AS CREATE_USER,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.CompanyControl z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.CompanyControl z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE
			) AS CREATE_DATA,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.CompanyControl z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.CompanyControl z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE DESC
			) AS UPDATE_DATA,
			CASE a.STATUS
				WHEN 3 THEN CONVERT(VARCHAR(20), a.EDATE, 104) + ' ' + CONVERT(VARCHAR(20), a.EDATE, 108) + '/' + a.UPD_USER
				ELSE ''
			END AS DELETE_DATA
		FROM Client.CompanyControl a
		WHERE a.ID_COMPANY = @ID
			AND (a.STATUS = 1 OR a.STATUS = 3 AND @DEL = 1)
		ORDER BY DATE DESC

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_CONTROL_SELECT] TO rl_control_r;
GO
