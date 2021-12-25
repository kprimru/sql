﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[KGS_DISTR_LIST_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[KGS_DISTR_LIST_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[KGS_DISTR_LIST_DELETE]
	@ID	INT
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
		FROM dbo.KGSDistr
		WHERE KD_ID_LIST = @ID

		DELETE
		FROM dbo.KGSDistrList
		WHERE KDL_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[KGS_DISTR_LIST_DELETE] TO rl_kgs_distr_d;
GO
