USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_WARNING_SELECT]
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
		SELECT a.ID, a.DATE, a.NOTIFY_USER, a.END_DATE, a.NOTE,
			CASE STATUS
				WHEN 1 THEN '�� ��������'
				WHEN 2 THEN '��������'
				WHEN 3 THEN '�������'
				WHEN 4 THEN '����� � ��������'
				ELSE '???'
			END AS STATUS_STR,
			STATUS,
			CREATE_USER,
			'' AS CREATE_DATA,
			'' AS UPDATE_DATA,
			'' AS DELETE_DATA
		FROM Client.CompanyWarning a
		WHERE a.ID_COMPANY = @ID
			AND (a.STATUS = 1 OR a.STATUS = 4 OR a.STATUS = 3 AND @DEL = 1 OR a.STATUS = 2 AND @DEL = 1)
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
GRANT EXECUTE ON [Client].[COMPANY_WARNING_SELECT] TO rl_company_warning_r;
GO