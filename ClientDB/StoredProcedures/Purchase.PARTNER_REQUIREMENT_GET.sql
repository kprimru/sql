﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PARTNER_REQUIREMENT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PARTNER_REQUIREMENT_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PARTNER_REQUIREMENT_GET]
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

		SELECT PR_NAME, PR_SHORT
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
GRANT EXECUTE ON [Purchase].[PARTNER_REQUIREMENT_GET] TO rl_partner_requirement_r;
GO
