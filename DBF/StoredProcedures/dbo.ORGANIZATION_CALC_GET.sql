USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ORGANIZATION_CALC_GET]
	@id SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			ORGC_ID, ORGC_NAME, ORG_ID, ORG_SHORT_NAME, BA_ID, BA_NAME, ORGC_ACCOUNT, ORGC_ACTIVE
		FROM
			dbo.OrganizationCalc INNER JOIN
			dbo.OrganizationTable ON ORGC_ID_ORG = ORG_ID INNER JOIN
			dbo.BankTable ON BA_ID = ORGC_ID_BANK
		WHERE ORGC_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ORGANIZATION_CALC_GET] TO rl_organization_calc_r;
GO