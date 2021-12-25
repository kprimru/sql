USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_JOURNAL_SELECT]
	@TYPE			INT,
	@BEGIN			SMALLDATETIME,
	@END			SMALLDATETIME,
	@AUTHOR			NVARCHAR(128),
	@PERSONAL		UNIQUEIDENTIFIER,
	@SENDER			UNIQUEIDENTIFIER,
	@COMPANY		NVARCHAR(256),
	@COMPANY_ID		UNIQUEIDENTIFIER,
	@AVAILABILITY	UNIQUEIDENTIFIER,
	@WORK_STATE		UNIQUEIDENTIFIER,
	@PAY_CAT		UNIQUEIDENTIFIER,
	@RC				INT = NULL OUTPUT
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
			a.ID AS ID, a.DATE, a.MESSAGE, b.NAME AS CL_NAME, b.ID AS CL_ID, e.NAME AS WS_NAME,
			c.SHORT, a.UPD_USER AS AUTHOR, f.NAME AS SN_NAME,
			g.NAME AS PC_NAME, d.NAME AS AVA_NAME
		FROM
			Client.CompanyProcessJournal a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Client.Availability d ON d.ID = b.ID_AVAILABILITY
			LEFT OUTER JOIN Client.WorkState e ON e.ID = b.ID_WORK_STATE
			LEFT OUTER JOIN Client.Sender f ON f.ID = b.ID_SENDER
			LEFT OUTER JOIN Client.PayCategory g ON g.ID = b.ID_PAY_CAT
		WHERE (TYPE = @TYPE OR @TYPE IS NULL)
			AND (DATE_S >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE_S <= @END OR @END IS NULL)
			AND (a.UPD_USER = @AUTHOR OR @AUTHOR IS NULL)
			AND (a.ID_PERSONAL = @PERSONAL OR @PERSONAL IS NULL)
			AND (ID_SENDER = @SENDER OR @SENDER IS NULL)
			AND (b.NAME LIKE @COMPANY OR b.SHORT LIKE @COMPANY OR @COMPANY IS NULL)
			AND (b.ID = @COMPANY_ID OR @COMPANY_ID IS NULL)
			AND (a.ID_AVAILABILITY = @AVAILABILITY OR @AVAILABILITY IS NULL)
			AND (ID_WORK_STATE = @WORK_STATE OR @WORK_STATE IS NULL)
			AND (ID_PAY_CAT = @PAY_CAT OR @PAY_CAT IS NULL)
		ORDER BY a.DATE DESC, b.NAME, a.TYPE

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
GRANT EXECUTE ON [Client].[COMPANY_JOURNAL_SELECT] TO rl_company_journal;
GO
