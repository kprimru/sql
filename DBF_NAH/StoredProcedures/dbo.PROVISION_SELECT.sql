USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROVISION_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, DATE, PRICE, PAY_NUM, ORG_SHORT_NAME, ORG_ID
	FROM
		dbo.Provision
		LEFT OUTER JOIN dbo.OrganizationTable ON ORG_ID = ID_ORG
	WHERE ID_CLIENT = @CLIENT
	ORDER BY DATE DESC
END

GO
GRANT EXECUTE ON [dbo].[PROVISION_SELECT] TO rl_income_r;
GO