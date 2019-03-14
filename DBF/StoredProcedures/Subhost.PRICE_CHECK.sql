USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[PRICE_CHECK]
	@PERIOD	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM 
		dbo.PriceSystemTable
		INNER JOIN dbo.PriceTypeTable ON PS_ID_TYPE = PT_ID
	WHERE PS_ID_PERIOD = @PERIOD
		AND PT_ID_GROUP IN (4, 5, 6, 7)
END
