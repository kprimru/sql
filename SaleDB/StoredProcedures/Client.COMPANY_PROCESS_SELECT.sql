USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@RC		INT				=	NULL OUTPUT
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
			a.ID, b.SHORT, PROCESS_TYPE,
			CASE PROCESS_TYPE
				WHEN N'PHONE' THEN N'ТА'
				WHEN N'SALE' THEN N'ТП'
				WHEN N'MANAGER' THEN N'Менеджер'
				WHEN N'RIVAL' THEN 'Конкурентный менеджер'
				ELSE N'???'
			END AS PROCESS_TYPE_CAPT,
			BDATE, EDATE,
			CONVERT(NVARCHAR(32), ASSIGN_DATE, 104) + ' ' +
				CONVERT(NVARCHAR(32), ASSIGN_DATE, 108) + ' ' + ASSIGN_USER AS ASSIGN_DATA
		FROM
			Client.CompanyProcess a
			INNER JOIN Personal.OfficePersonal b ON a.ID_PERSONAL = b.ID
		WHERE ID_COMPANY = @ID
		ORDER BY ASSIGN_DATE DESC

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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_SELECT] TO rl_company_process_r;
GO
