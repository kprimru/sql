USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_SELECT?SIMPLE]
	@FILTER	NVARCHAR(256)	= NULL,
	@RC		INT				= NULL OUTPUT
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
		SET @FILTER = Replace(@Filter, '%', '')

		SELECT
			A.ID, b.NUMBER, b.STATUS,
			t.ADDRESS AS SHORT, b.NAME,
			d.NAME AS AVA_NAME, e.NAME AS POT_NAME, f.NAME AS WS_NAME, g.NAME AS PC_NAME,
			h.SHORT AS PHONE_SHORT, j.SHORT AS SALE_SHORT,
			WORK_DATE, q.NAME AS CHAR_NAME, PAPER_CARD, DEPO = Cast(IsNull(DP.IsDepo, 0) AS Bit),
			DEPO_NUM = DP.Number
		FROM Client.CompanyReadList() AS A
		INNER JOIN Client.Company b ON A.ID = b.ID
		LEFT JOIN Client.CompanyIndex t ON t.ID_COMPANY = A.ID
		LEFT JOIN Client.Availability d ON d.ID = b.ID_AVAILABILITY
		LEFT JOIN Client.Potential e ON e.ID = b.ID_POTENTIAL
		LEFT JOIN Client.WorkState f ON f.ID = b.ID_WORK_STATE
		LEFT JOIN Client.PayCategory g ON g.ID = b.ID_PAY_CAT
		LEFT JOIN Client.CompanyProcessPhoneView h WITH(NOEXPAND) ON h.ID = b.ID
		LEFT JOIN Client.CompanyProcessSaleView j WITH(NOEXPAND) ON j.ID = b.ID
		LEFT JOIN Client.Character q ON q.ID = b.ID_CHARACTER
		OUTER APPLY
		(
			SELECT TOP (1)
				DP.[Number],
				IsDepo = 1
			FROM Client.CompanyDepo DP
			WHERE DP.Company_Id = a.ID
				AND DP.Status = 1
				-- ToDo убрать хардкод
				AND DP.Status_Id IN (3)
			ORDER BY DP.DateFrom DESC
		) AS DP
		WHERE	(b.NAME LIKE '%' + @FILTER + '%' OR @FILTER IS NULL)
			OR	(Cast(b.NUMBER AS VarChar(100)) = @FILTER OR @FILTER IS NULL)
		ORDER BY b.NAME, b.NUMBER


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
GRANT EXECUTE ON [Client].[COMPANY_SELECT?SIMPLE] TO rl_company_r;
GO