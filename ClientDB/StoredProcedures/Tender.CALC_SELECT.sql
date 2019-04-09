USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[CALC_SELECT]
	@TENDER UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ID, a.NAME, b.NAME AS DIR_NAME, a.PRICE, a.NOTE
	FROM 
		Tender.Calc a
		INNER JOIN Tender.CalcDirection b ON a.ID_DIRECTION = b.ID
	WHERE a.ID_TENDER = @TENDER AND a.STATUS = 1
	ORDER BY a.DATE DESC
END
