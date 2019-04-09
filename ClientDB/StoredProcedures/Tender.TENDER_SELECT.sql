USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[TENDER_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ID, INFO_DATE, CALL_DATE,
		b.NAME AS LAW_NAME,
		c.NAME AS STAT_NAME
	FROM 
		Tender.Tender a
		INNER JOIN Tender.Status c ON a.ID_STATUS = c.ID
		LEFT OUTER JOIN Tender.Law b ON a.ID_LAW = b.ID
	WHERE ID_CLIENT = @CLIENT AND STATUS = 1
	ORDER BY INFO_DATE DESC
END
