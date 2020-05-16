USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_ARCHIVE_SELECT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@NAME	NVARCHAR(256),
	@PER	UNIQUEIDENTIFIER,
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
		IF @END IS NOT NULL
			SET @END = DATEADD(DAY, 1, @END)

		SELECT
			a.ID, b.ID AS CO_ID, b.NUMBER AS CO_NUM, b.NAME, a.BDATE, a.UPD_USER,
			CONVERT(BIT,
				CASE
					WHEN m.ID IS NULL THEN 0
					ELSE 1
				END
			) AS CONTROL
		FROM
			Client.CompanyArchive a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			LEFT OUTER JOIN (SELECT DISTINCT ID, ID_COMPANY FROM Client.CompanyControlView WITH(NOEXPAND)) AS m ON m.ID_COMPANY = a.ID
			LEFT OUTER JOIN Personal.OfficePersonal c ON c.[LOGIN] = a.UPD_USER
		WHERE a.STATUS = 1
			AND b.STATUS = 1
			AND (b.NAME LIKE @NAME OR CONVERT(NVARCHAR(32), NUMBER) LIKE @NAME OR @NAME IS NULL)
			AND (a.BDATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.BDATE < @END OR @END IS NULL)
			AND (@PER IS NULL OR c.ID = @PER)
		ORDER BY b.NAME

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
GRANT EXECUTE ON [Client].[COMPANY_ARCHIVE_SELECT] TO rl_archive_apply;
GO