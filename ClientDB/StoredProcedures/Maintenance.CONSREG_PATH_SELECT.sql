﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[CONSREG_PATH_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[CONSREG_PATH_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[CONSREG_PATH_SELECT]
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

		SELECT [CONSREG_PATH] = Cast([Maintenance].[GlobalSetting@Get]('CONSREG_PATH') AS VarChar(256));

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[CONSREG_PATH_SELECT] TO public;
GO
