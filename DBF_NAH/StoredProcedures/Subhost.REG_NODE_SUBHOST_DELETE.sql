﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[REG_NODE_SUBHOST_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[REG_NODE_SUBHOST_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[REG_NODE_SUBHOST_DELETE]
	@RNS_ID BIGINT
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
		FROM Subhost.RegNodeSubhostTable
		WHERE RNS_ID = @RNS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[REG_NODE_SUBHOST_DELETE] TO rl_subhost_calc;
GO
