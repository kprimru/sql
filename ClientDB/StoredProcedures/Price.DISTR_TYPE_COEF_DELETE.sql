﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[DISTR_TYPE_COEF_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[DISTR_TYPE_COEF_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[DISTR_TYPE_COEF_DELETE]
	@NET		Int,
	@PERIOD		UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @PERIOD;

		DELETE [Price].[DistrType:Coef]
		WHERE [DistrType_Id] = @NET
			AND [Date] = @Date;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
