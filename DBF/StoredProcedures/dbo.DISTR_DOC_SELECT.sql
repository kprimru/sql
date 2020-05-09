USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_DOC_SELECT]
	@distrid INT
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

		SELECT
			DOC_ID, DOC_NAME,
			DD_ID, ISNULL(DD_PRINT, 1) AS DD_PRINT,
			GD_ID, GD_NAME,
			UN_ID, UN_NAME
		FROM 
			dbo.DistrDocumentView
		WHERE DIS_ID = @distrid	--AND ISNULL(DD_ID_DOC, DOC_ID) = DOC_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_DOC_SELECT] TO rl_distr_financing_r;
GO