USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_SELECT]
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
			a.ID, (ISNULL(a.SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(a.PATRON, '')) AS FIO,
			a.SURNAME, a.NAME, a.PATRON, a.EMAIL, a.MAILING,
			b.NAME AS OFFICE, c.NAME AS POSITION, a.NOTE,
			REVERSE(STUFF(REVERSE((
				SELECT ISNULL(b.NAME + ': ', '') + PHONE + ISNULL(' ' + NOTE, '') + ', '
				FROM
					Client.CompanyPersonalPhone z
					LEFT OUTER JOIN Client.PhoneType y ON z.ID_TYPE = y.ID
				WHERE z.ID_PERSONAL = a.ID AND z.STATUS=1
				ORDER BY y.NAME, PHONE FOR XML PATH('')
			)), 1, 2, '')) AS PHONES, a.STATUS,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.CompanyPersonal z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.CompanyPersonal z
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
						FROM Client.CompanyPersonal z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.CompanyPersonal z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE DESC
			) AS UPDATE_DATA,
			CASE a.STATUS
				WHEN 3 THEN CONVERT(VARCHAR(20), a.EDATE, 104) + ' ' + CONVERT(VARCHAR(20), a.EDATE, 108) + '/' + a.UPD_USER
				ELSE ''
			END AS DELETE_DATA
		FROM
			Client.CompanyPersonal a
			LEFT OUTER JOIN Client.Office b ON a.ID_OFFICE = b.ID
			LEFT OUTER JOIN Client.Position c ON c.ID = a.ID_POSITION
		WHERE a.ID_COMPANY = @ID
			AND (a.STATUS = 1 OR a.STATUS = 3 AND @DEL = 1)
		ORDER BY a.SURNAME, a.NAME, a.PATRON, b.NAME

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
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_SELECT] TO rl_company_personal_r;
GO
