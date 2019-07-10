USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_PRICE_SYSTEM_SELECT]
	@ACTIVE BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SPS_ID, 
		SYS_ID, SYS_SHORT_NAME, 
		PR_ID, PR_DATE, 
		PT_ID, PT_NAME, 
		SH_ID, SH_SHORT_NAME, 
		SPS_PRICE
	FROM 
		Subhost.SubhostPriceSystemTable INNER JOIN
		dbo.SystemTable ON SPS_ID_SYSTEM = SYS_ID INNER JOIN
		dbo.PriceTypeTable ON SPS_ID_TYPE = PT_ID INNER JOIN
		dbo.SubhostTable ON SPS_ID_HOST = SH_ID INNER JOIN
		dbo.PeriodTable ON SPS_ID_PERIOD = PR_ID
	WHERE SPS_ACTIVE = ISNULL(@ACTIVE, SPS_ACTIVE)
	ORDER BY PR_DATE DESC, SH_SHORT_NAME, SYS_ORDER
END
