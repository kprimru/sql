USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[OTHER_SERVICE_SELECT]
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
		SELECT a.ID, a.NAME, b.PRICE
		FROM
			Price.OtherService a
			LEFT OUTER JOIN
				(
					SELECT b.ID_SERVICE, b.PRICE
					FROM
						Price.OtherServicePrice b
						INNER JOIN Common.Month c ON b.ID_PERIOD = c.ID AND c.DATE <= GETDATE() AND DATEADD(MONTH, 1, c.DATE) > GETDATE()
				) AS b ON a.ID = b.ID_SERVICE
		ORDER BY a.ORD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Price].[OTHER_SERVICE_SELECT] TO rl_offer_r;
GO