USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[OFFER_MASTER_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		QUERY_DATE, SUPPORT_START, SUPPORT_FINISH, '' AS TPL,
		'В ' + d.CLIENT AS CLIENT_HEADER, d.CLIENT AS CLIENT_FULL_NAME,
		b.FULL_NAME AS VENDOR_SHORT, b.DIRECTOR AS VENDOR_DIRECTOR, b.OFFICIAL AS VENDOR_FULL, c.NAME AS NDS_DATA,
		REVERSE(STUFF(REVERSE((
			SELECT y.NAME + ', '
			FROM
				(
					SELECT ID
					FROM
						dbo.TableGuidFromXML(a.SUPPORT_TYPES)
					
					UNION
					
					SELECT ID
					FROM
						dbo.TableGuidFromXML(a.DELIVERY_TYPES)
					
					UNION
					
					SELECT ID
					FROM
						dbo.TableGuidFromXML(a.EXCHANGE_TYPES)
					
					UNION
					
					SELECT ID
					FROM
						dbo.TableGuidFromXML(a.ACTUAL_TYPES)
				) AS z
				INNER JOIN Tender.SystemType y ON z.ID = y.ID
			ORDER BY y.NAME FOR XML PATH('')
		)), 1, 2, '')) AS SYSTEM_TYPES,
		CASE
			WHEN DELIVERY = 1 THEN 'допоставку экземпляров систем'
			ELSE ''
		END + 
		CASE
			WHEN ACTUAL = 1 AND DELIVERY = 1 THEN ', актуализацию экземпляров систем'
			WHEN ACTUAL = 1 AND DELIVERY = 0 THEN 'актуализацию экземпляров систем'
			ELSE ''
		END + 	
		CASE
			WHEN EXCHANGE = 1 AND (DELIVERY = 1 OR ACTUAL = 1) THEN ', замену экземпляров систем'
			WHEN EXCHANGE = 1 AND DELIVERY = 0 AND ACTUAL = 0 THEN 'замену экземпляров систем'
			ELSE ''
		END + 	
		CASE
			WHEN SUPPORT = 1 AND (ACTUAL = 1 OR EXCHANGE = 1 OR DELIVERY = 1) THEN ' и оказания информационных услуг'
			WHEN SUPPORT = 1 AND ACTUAL = 0 AND EXCHANGE = 0 AND DELIVERY = 0 THEN 'оказания информационных услуг'
			ELSE ''
		END AS DATA,
		(
			SELECT SUM(ACTUAL)
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_ACTUAL,
		(
			SELECT SUM(DELIVERY)
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_DELIVERY,
		(
			SELECT SUM(EXCHANGE)
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_EXCHANGE,
		(
			SELECT SUM(SUPPORT)
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_SUPPORT,
		(
			SELECT SUM(SUPPORT_TOTAL)
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_SUPPORT_TOTAL,
		(
			SELECT SUM(ISNULL(SUPPORT_TOTAL, 0) + ISNULL(DELIVERY, 0) + ISNULL(ACTUAL, 0) + ISNULL(EXCHANGE, 0))
			FROM Tender.OfferDetail
			WHERE ID_OFFER = @ID
		) AS TOTAL_ALL
	FROM 
		Tender.Offer a
		INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
		INNER JOIN Common.Tax c ON a.ID_TAX = c.ID
		INNER JOIN Tender.Tender d ON a.ID_TENDER = d.ID
	WHERE a.ID = @ID
END
