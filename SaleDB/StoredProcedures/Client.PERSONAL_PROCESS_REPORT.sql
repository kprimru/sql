USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[PERSONAL_PROCESS_REPORT]
	@ID		UNIQUEIDENTIFIER,
	@TYPE	NVARCHAR(MAX),
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@RC		INT = NULL OUTPUT,
	@GIVE	INT = NULL OUTPUT,
	@RETURN	INT = NULL OUTPUT
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
		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				ID			UNIQUEIDENTIFIER,
				NAME		NVARCHAR(512),
				PROC_TYPE	NVARCHAR(128),
				ASSIGN_DATE	DATETIME,
				RETURN_DATE	DATETIME
			)

		INSERT INTO #temp(ID, NAME, PROC_TYPE, ASSIGN_DATE, RETURN_DATE)
			SELECT b.ID, b.NAME,
				CASE PROCESS_TYPE
					WHEN N'MANAGER' THEN N'Менеджер'
					WHEN N'SALE' THEN N'ТП'
					WHEN N'PHONE' THEN N'ТА'
					WHEN N'RIVAL' THEN 'КМ'
					ELSE N'???'
				END AS PROC_TYPE,
				ASSIGN_DATE, RETURN_DATE
			FROM
				Client.CompanyProcess a
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				INNER JOIN Common.TableStringFromXML(@TYPE) c ON c.ID = PROCESS_TYPE
			WHERE ID_PERSONAL = @ID
				AND
					(
						a.BDATE BETWEEN @BEGIN AND @END
						OR
						a.EDATE BETWEEN @BEGIN AND @END
					)
			ORDER BY NAME, PROC_TYPE

		SELECT @RC = @@ROWCOUNT

		SELECT @GIVE = COUNT(*)
		FROM #temp
		WHERE ASSIGN_DATE IS NOT NULL

		SELECT @RETURN = COUNT(*)
		FROM #temp
		WHERE RETURN_DATE IS NOT NULL

		SELECT ID, NAME, PROC_TYPE, ASSIGN_DATE, RETURN_DATE
		FROM #temp
		ORDER BY NAME, PROC_TYPE

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[PERSONAL_PROCESS_REPORT] TO rl_personal_process_report;
GO