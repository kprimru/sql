USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DELETE_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@NAME	NVARCHAR(512),
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
		SET @END = DATEADD(DAY, 1, @END)

		SELECT ID, NAME, NUMBER, EDATE, UPD_USER
		FROM Client.Company a
		WHERE STATUS = 3
			AND (EDATE >= @BEGIN OR @BEGIN IS NULL)
			AND (EDATE < @END OR @END IS NULL)
			AND (NAME LIKE @NAME OR CONVERT(NVARCHAR(128), NUMBER) LIKE @NAME OR @NAME IS NULL)
			AND EXISTS
				(
					SELECT *
					FROM Client.Company b
					WHERE b.ID_MASTER = a.ID
				)
		ORDER BY NAME

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
GRANT EXECUTE ON [Client].[COMPANY_DELETE_REPORT] TO rl_company_delete_report;
GO
