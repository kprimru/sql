USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONSIGNMENT_FACT_GET]
	@clientid INT,
	@date VARCHAR(100)
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

		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT *
		FROM dbo.ConsignmentFactMasterTable
		WHERE CFM_DATE = @d AND CL_ID = @clientid

		SELECT ConsignmentFactDetailTable.*
		FROM
			dbo.ConsignmentFactDetailTable INNER JOIN
			dbo.ConsignmentFactMasterTable ON CFD_ID_CFM = CFM_ID
		WHERE CFM_DATE = @d

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_CONSIGNMENT_FACT_GET] TO rl_consignment_p;
GO
