﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[PLACEMENT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[PLACEMENT_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[PLACEMENT_GET]
	@TENDER	UNIQUEIDENTIFIER
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

		SELECT *
		FROM Tender.Placement
		WHERE ID_TENDER = @TENDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[PLACEMENT_GET] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[PLACEMENT_GET] TO rl_tender_u;
GO
