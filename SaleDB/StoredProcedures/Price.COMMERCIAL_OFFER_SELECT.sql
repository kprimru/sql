USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OFFER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_SELECT]
	@CLIENT	UNIQUEIDENTIFIER,
	@RC		INT = NULL OUTPUT
WITH EXECUTE AS OWNER
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
		ID, DATE, NUM, NOTE,
		REVERSE(STUFF(REVERSE((
			SELECT SYS_STR + ', '
			FROM Price.CommercialOfferView b
			WHERE b.ID_OFFER = a.ID
			ORDER BY SYS_ORDER FOR XML PATH('')
		)), 1, 2, '')) +
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM Price.CommercialOfferOther z
					WHERE z.ID_OFFER = a.ID
				) THEN ', флэш-носитель'
			ELSE ''
		END AS SYS_STR,
		CONVERT(VARCHAR(20), CREATE_DATE, 104) + ' ' + CREATE_USER AS CREATE_DATA
	FROM Price.CommercialOffer a
	WHERE ID_CLIENT = @CLIENT
		AND STATUS = 1

	ORDER BY DATE, NUM DESC

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_SELECT] TO rl_offer_r;
GO
