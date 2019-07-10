USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORGANIZATION_CALC_SELECT] 
    @active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		ORGC_ID, ORGC_NAME, ORG_SHORT_NAME, BA_NAME, ORGC_ACCOUNT
	FROM 
		dbo.OrganizationCalc INNER JOIN 
		dbo.OrganizationTable ON ORGC_ID_ORG = ORG_ID INNER JOIN
		dbo.BankTable ON BA_ID = ORGC_ID_BANK
	WHERE ORGC_ACTIVE = ISNULL(@active, ORGC_ACTIVE)
	ORDER BY ORGC_NAME

	SET NOCOUNT OFF
END
