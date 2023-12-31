USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DELIVERY_FILTER]
	@START			SMALLDATETIME,
	@FINISH			SMALLDATETIME,
	@PLAN_START		SMALLDATETIME,
	@PLAN_FINISH	SMALLDATETIME,
	@STATE			SMALLINT,
	@PERSONAL		NVARCHAR(128)
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

	SELECT
		b.ID, b.NAME, b.NUMBER, a.PERSONAL AS SHORT, a.FIO, a.POS, a.EMAIL, a.DATE, a.PLAN_DATE, a.OFFER,
		CASE a.STATE WHEN 1 THEN '��������' WHEN 2 THEN '���� � ��������' ELSE '???' END AS STATE_STR
	FROM
		Client.CompanyDelivery a
		INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
	WHERE (@STATE IS NULL OR @STATE = 0 OR STATE = @STATE)
		AND (DATE >= @START OR @START IS NULL)
		AND (DATE <= @FINISH OR @FINISH IS NULL)
		AND (PLAN_DATE >= @PLAN_START OR @PLAN_START IS NULL)
		AND (PLAN_DATE <= @PLAN_FINISH OR @PLAN_FINISH IS NULL)
		AND (a.PERSONAL = @PERSONAL OR @PERSONAL IS NULL)
	ORDER BY b.NAME
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DELIVERY_FILTER] TO rl_delivery_filter;
GO
