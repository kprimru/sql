USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_GET]
	@ID	UNIQUEIDENTIFIER
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
			a.ID, SHORT, NAME, A.NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_AVAILABILITY,
			ID_NEXT_MON, ID_ACTIVITY, ACTIVITY_NOTE, ID_SENDER, SENDER_NOTE, WORK_DATE, ID_TAXING,
			ID_REMOTE, ID_CHARACTER, ID_WORK_STATUS, EMAIL, BLACK_LIST, BLACK_NOTE, WORK_BEGIN, CARD,
			PAPER_CARD, DATE, ID_PROJECT, DEPO_NUM = D.Number, DEPO = Cast(IsNull(D.IsDepo, 0) AS Bit),
			(
				SELECT '{' + CONVERT(NVARCHAR(64), z.ID_TAXING) + '}' AS '@id'
				FROM Client.CompanyTaxing z
				WHERE z.ID_COMPANY = a.ID
				FOR XML PATH('item'), ROOT('root')
			) AS TAXING_LIST,
			(
				SELECT '{' + CONVERT(NVARCHAR(64), z.ID_ACTIVITY) + '}' AS '@id'
				FROM Client.CompanyActivity z
				WHERE z.ID_COMPANY = a.ID
				FOR XML PATH('item'), ROOT('root')
			) AS ACTIVITY_LIST,
			(
				SELECT '{' + CONVERT(NVARCHAR(64), z.ID_PROJECT) + '}' AS '@id'
				FROM Client.CompanyProject z
				WHERE z.ID_COMPANY = a.ID
				FOR XML PATH('item'), ROOT('root')
			) AS PROJECT_LIST
		FROM Client.Company a
		LEFT JOIN Client.CallDate b ON a.ID = b.ID_COMPANY
		OUTER APPLY
		(
			SELECT TOP (1)
				D.[Number],
				IsDepo = 1
			FROM Client.CompanyDepo D
			WHERE D.Company_Id = a.ID
				AND D.Status = 1
				-- ToDo убрать хардкод
				AND D.Status_Id IN (1, 2, 3)
			ORDER BY D.DateFrom DESC
		) AS D
		WHERE	a.ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_GET] TO rl_company_r;
GO
