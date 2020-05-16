USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_SELECT]
	@COMPANY	UNIQUEIDENTIFIER,
	@RC			INT	= NULL OUTPUT
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
			a.ID, a.DATE, b.NAME AS OF_NAME,
			REVERSE(STUFF(REVERSE((
				SELECT y.SHORT + '(' + x.SHORT + '), '
				FROM
					Sale.SaleDistr z
					INNER JOIN System.Systems y ON z.ID_SYSTEM = y.ID
					INNER JOIN System.Net x ON z.ID_NET = x.ID
				WHERE z.ID_SALE = a.ID
				ORDER BY ORD FOR XML PATH('')
			)), 1, 2, '')) AS SYS_STR,
			REVERSE(STUFF(REVERSE((
				SELECT y.SHORT + '(' + CONVERT(VARCHAR(20), [VALUE]) + '), '
				FROM
					Sale.SalePersonal z
					INNER JOIN Personal.OfficePersonal y ON z.ID_PERSONAL = y.ID
				WHERE z.ID_SALE = a.ID
				ORDER BY [VALUE] DESC, y.SHORT FOR XML PATH('')
			)), 1, 2, '')) AS PERS_STR,
			c.SHORT AS PER_SHORT, d.NAME AS RIVAL_NAME,
			a.STATUS, a.CONFIRMED,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Sale.SaleCompany z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Sale.SaleCompany z
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
						FROM Sale.SaleCompany z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Sale.SaleCompany z
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
			Sale.SaleCompany a
			LEFT OUTER JOIN Client.Office b ON a.ID_OFFICE = b.ID
			LEFT OUTER JOIN Personal.OfficePersonal c ON c.ID = a.ID_ASSIGNER
			LEFT OUTER JOIN Client.RivalSystem d ON d.ID = a.ID_RIVAL
		WHERE a.STATUS = 1
			AND a.ID_COMPANY = @COMPANY
		ORDER BY DATE

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
GRANT EXECUTE ON [Sale].[COMPANY_SALE_SELECT] TO rl_sale_r;
GO