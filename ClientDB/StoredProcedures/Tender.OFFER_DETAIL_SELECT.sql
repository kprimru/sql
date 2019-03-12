USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Tender].[OFFER_DETAIL_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 		
		ID, ID_CLIENT, CLIENT, ADDRESS, 
		CLIENT + ' (' + ADDRESS + ')' AS CL_STR,
		ID_SYSTEM, ID_OLD_SYSTEM, DISTR, ID_NET, ID_OLD_NET,
		CASE 
			WHEN d.SystemID IS NULL OR d.SystemID = b.SystemID THEN b.SystemShortName 
			ELSE '� ' + d.SystemShortName + ' �� ' + b.SystemShortName 
		END AS SYS_STR,
		CASE 
			WHEN e.DistrTypeID IS NULL OR e.DistrTypeID = c.DistrTypeID THEN c.DistrTypeName
			ELSE '� ' + e.DistrTypeName + ' �� ' + c.DistrTypeName 
		END AS NET_STR,
		DELIVERY_BASE, DELIVERY,
		EXCHANGE_BASE, EXCHANGE,
		ACTUAL_BASE, ACTUAL,
		SUPPORT_BASE, SUPPORT,
		SUPPORT_TOTAL,
		MON_CNT
	FROM 
		Tender.OfferDetail a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		INNER JOIN dbo.DistrTypeTable c ON a.ID_NET = c.DistrTypeID
		LEFT OUTER JOIN dbo.SystemTable d ON a.ID_OLD_SYSTEM = d.SystemID
		LEFT OUTER JOIN dbo.DistrTypeTable e ON a.ID_OLD_NET = e.DistrTypeID
	WHERE a.ID_OFFER = @ID
	ORDER BY CLIENT, ADDRESS, b.SystemOrder, c.DistrTypeCoef, DISTR
END
