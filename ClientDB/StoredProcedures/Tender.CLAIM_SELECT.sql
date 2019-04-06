USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[CLAIM_SELECT]
	@TENDER	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, TP,
		CASE TP 
			WHEN 1 THEN 'Обеспечение заявки' 
			WHEN 2 THEN 'Обеспечение контракта' 
			WHEN 3 THEN 'Оплата за участие'
			WHEN 4 THEN 'Оплата за тариф'
			WHEN 5 THEN 'Оплата за ЭЦП'
			WHEN 6 THEN 'Оплата за ЭДО'
			ELSE 'Неведома зверушка' 
		END AS TP_STR, 
		CLAIM_DATE
	FROM Tender.Claim
	WHERE ID_TENDER = @TENDER
	ORDER BY CLAIM_DATE DESC
END
