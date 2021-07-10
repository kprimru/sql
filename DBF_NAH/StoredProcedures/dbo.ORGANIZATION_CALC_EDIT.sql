USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ORGANIZATION_CALC_EDIT]
	@id SMALLINT,
	@name VARCHAR(128),
	@org SMALLINT,
	@bankid SMALLINT,
	@acc VARCHAR(50),
	@active BIT = 1
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

		UPDATE dbo.OrganizationCalc
		SET ORGC_NAME = @name,
			ORGC_ID_ORG = @org,
			ORGC_ID_BANK = @bankid,
			ORGC_ACCOUNT = @acc,
			ORGC_ACTIVE = @active
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
GRANT EXECUTE ON [dbo].[ORGANIZATION_CALC_EDIT] TO rl_organization_calc_w;
GO