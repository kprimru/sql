USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_CONTROL_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_CONTROL_WARNING]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_CONTROL_WARNING]
	@RC	INT = NULL OUTPUT
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
		DECLARE @CURDATE SMALLDATETIME

		IF IS_MEMBER('rl_control_notify_all') = 1
			SELECT b.ID, b.NAME, Common.DateOf(c.DATE) AS DATE, c.NOTE, e.SHORT, f.SHORT AS PHONE_SHORT, g.SHORT AS MAN_SHORT, c.NOTIFY_DATE, b.NUMBER
			FROM
				Client.CompanyControlView a WITH(NOEXPAND)
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				INNER JOIN Client.CompanyControl c ON c.ID = a.ID
				LEFT OUTER JOIN Client.CompanyProcessSaleView e WITH(NOEXPAND) ON e.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessPhoneView f WITH(NOEXPAND) ON f.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessManagerView g WITH(NOEXPAND) ON g.ID = b.ID
			WHERE b.STATUS = 1
				AND (c.NOTIFY_DATE <= DATEADD(DAY, 2, GETDATE()) OR c.NOTIFY_DATE IS NULL)
			ORDER BY b.NAME, c.DATE
		ELSE
			SELECT b.ID, b.NAME, Common.DateOf(c.DATE) AS DATE, c.NOTE, e.SHORT, f.SHORT AS PHONE_SHORT, g.SHORT AS MAN_SHORT, c.NOTIFY_DATE, b.NUMBER
			FROM
				Client.CompanyControlView a WITH(NOEXPAND)
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				INNER JOIN Client.CompanyControl c ON c.ID = a.ID
				INNER JOIN Client.CompanyWriteList() d ON d.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessSaleView e WITH(NOEXPAND) ON e.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessPhoneView f WITH(NOEXPAND) ON f.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessManagerView g WITH(NOEXPAND) ON g.ID = b.ID
			WHERE b.STATUS = 1
				AND (c.NOTIFY_DATE <= DATEADD(DAY, 2, GETDATE()) OR c.NOTIFY_DATE IS NULL)
			ORDER BY b.NAME, c.DATE

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
GRANT EXECUTE ON [Client].[COMPANY_CONTROL_WARNING] TO rl_control_notify_all;
GRANT EXECUTE ON [Client].[COMPANY_CONTROL_WARNING] TO rl_control_notify_self;
GO
