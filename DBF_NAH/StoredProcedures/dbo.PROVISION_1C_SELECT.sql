USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROVISION_1C_SELECT]
	@date	SMALLDATETIME,
	@org	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CL_ID, CL_PSEDO, CL_INN,
		DATE, PAY_NUM, PRICE
	FROM
		dbo.Provision a
		INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.CL_ID
	WHERE DATE = @DATE AND ID_ORG = @ORG
		AND PRICE > 0
	ORDER BY CL_PSEDO
END
GO
GRANT EXECUTE ON [dbo].[PROVISION_1C_SELECT] TO rl_report_act_r;
GO