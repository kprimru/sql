USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[COMPLIANCE_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@SHORT	VARCHAR(100),
	@ORDER	INT
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

		UPDATE dbo.ComplianceTypeTable
		SET ComplianceTypeName = @NAME,
			ComplianceTypeShortName = @SHORT,
			ComplianceTypeOrder = @ORDER
		WHERE ComplianceTypeID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[COMPLIANCE_TYPE_UPDATE] TO rl_compliance_type_u;
GO