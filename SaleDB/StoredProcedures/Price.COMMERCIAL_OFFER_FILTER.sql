USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@CLIENT	VARCHAR(200),
	@STATUS	INT,
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

	SELECT
		a.ID, DATE, NOTE, b.SHORT,
		ISNULL(d.NAME, a.FULL_NAME) AS ClientName, d.ID AS CO_ID,
		a.CREATE_USER AS Manager,
		CONVERT(VARCHAR(20), CREATE_DATE, 104) + ' ' + CREATE_USER AS CREATE_DATA
	FROM
		Price.CommercialOffer a
		INNER JOIN Price.OfferTemplate b ON a.ID_TEMPLATE = b.ID
		LEFT OUTER JOIN Client.Company d ON d.ID = a.ID_CLIENT
	WHERE a.STATUS = 1 AND d.STATUS = 1
		AND (DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (DATE <= @END OR @END IS NULL)
		--AND (a.FULL_NAME LIKE @CLIENT OR d.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		--AND (@STATUS = 0 OR @STATUS = 1 AND d.ClientID IS NOT NULL OR @STATUS = 2 AND d.ClientID IS NULL OR @STATUS IS NULL)
	ORDER BY DATE DESC, ClientName

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_FILTER] TO rl_offer_r;
GO
