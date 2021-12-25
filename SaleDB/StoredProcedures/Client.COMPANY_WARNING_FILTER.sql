USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_WARNING_FILTER]
	@TYPE		TINYINT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TEXT		VARCHAR(500),
	@PERS		UNIQUEIDENTIFIER,
	@RC			INT = NULL OUTPUT
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
		SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		CREATE TABLE #words
				(
					WRD		VARCHAR(250) PRIMARY KEY
				)

		IF @TEXT IS NOT NULL
			INSERT INTO #words(WRD)
				SELECT '%' + Word + '%'
				FROM Common.SplitString(@TEXT)

		SELECT
			b.ID AS ID,
			b.NAME AS CO_NAME, DATE, NOTE, END_DATE, b.NUMBER,
			ISNULL((SELECT TOP 1 SHORT FROM Personal.OfficePersonal WHERE LOGIN = a.UPD_USER), a.UPD_USER) AS CONTROL_USER
		FROM
			Client.CompanyWarning a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			--INNER JOIN Client.CompanyReadList() c ON c.ID = b.ID
		WHERE --a.ID_MASTER IS NULL
			a.STATUS = 1
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE < @END OR @END IS NULL)
			AND (@PERS IS NULL OR (SELECT TOP 1 ID FROM Personal.OfficePersonal WHERE [LOGIN] = a.UPD_USER) = @PERS OR (SELECT TOP 1 ID FROM Personal.OfficePersonal WHERE [LOGIN] = a.CREATE_USER) = @PERS)
			AND (@TYPE IS NULL OR @TYPE = 0 OR @TYPE = 1 AND END_DATE IS NULL OR @TYPE = 2 AND END_DATE IS NOT NULL)
			AND
				(
					@TEXT IS NULL
					OR
					NOT EXISTS
						(
							SELECT *
							FROM #words
							WHERE NOT(NOTE LIKE WRD)
						)
				)
		ORDER BY DATE DESC, CO_NAME

		SELECT @RC = @@ROWCOUNT

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_WARNING_FILTER] TO rl_company_warning_r;
GO
