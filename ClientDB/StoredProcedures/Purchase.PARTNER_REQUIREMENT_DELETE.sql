USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PARTNER_REQUIREMENT_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PARTNER_REQUIREMENT_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[PARTNER_REQUIREMENT_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM Purchase.ClientConditionPartnerRequirement
		WHERE CCPR_ID_PR = @ID

		DELETE
		FROM Purchase.PartnerRequirement
		WHERE PR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PARTNER_REQUIREMENT_DELETE] TO rl_partner_requirement_d;
GO
