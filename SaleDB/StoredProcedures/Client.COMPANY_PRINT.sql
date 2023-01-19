USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PRINT]
	@ID		UNIQUEIDENTIFIER
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
			a.NAME AS CO_NAME, a.NUMBER,
			REVERSE(STUFF(REVERSE(
				(
					SELECT l.NAME + ', '
					FROM
						Client.CompanyActivity t
						INNER JOIN Client.Activity l ON t.ID_ACTIVITY = l.ID
					WHERE t.ID_COMPANY = a.ID
				)
			), 1, 2, '')) AS AC_NAME,
			ACTIVITY_NOTE, a.WORK_DATE,
			e.NAME AS WORK_STATUS, f.NAME AS WORK_STATE, g.NAME AS REMOTENAME, h.NAME AS AVAILABILITY,
			j.NAME AS CHAR_NAME, i.NAME AS MONTH_NAME, k.NAME AS PAY_CAT_NAME, b.NAME AS SEN_NAME, a.SENDER_NOTE,
			c.NAME AS POT_NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT l.NAME + ', '
					FROM
						Client.CompanyTaxing t
						INNER JOIN Client.Taxing l ON t.ID_TAXING = l.ID
					WHERE t.ID_COMPANY = a.ID
				)
			), 1, 2, '')) AS TX_NAME
		FROM
			Client.Company a
			LEFT OUTER JOIN Client.Activity d ON a.ID_ACTIVITY = d.ID
			LEFT OUTER JOIN Client.WorkStatus e ON a.ID_WORK_STATUS = e.ID
			LEFT OUTER JOIN Client.WorkState f ON a.ID_WORK_STATE = f.ID
			LEFT OUTER JOIN Client.Remote g ON a.ID_REMOTE = g.ID
			LEFT OUTER JOIN Client.Availability h ON a.ID_AVAILABILITY = h.ID
			LEFT OUTER JOIN Client.Character j ON a.ID_CHARACTER = j.ID
			LEFT OUTER JOIN Common.Month i ON a.ID_NEXT_MON = i.ID
			LEFT OUTER JOIN Client.PayCategory k ON a.ID_PAY_CAT = k.ID
			LEFT OUTER JOIN Client.Sender b ON b.ID = a.ID_SENDER
			LEFT OUTER JOIN Client.Potential c ON c.ID = a.ID_POTENTIAL
			--LEFT OUTER JOIN Client.Taxing l ON l.ID = a.ID_TAXING
		WHERE a.STATUS = 1 AND a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PRINT] TO rl_company_p;
GO
