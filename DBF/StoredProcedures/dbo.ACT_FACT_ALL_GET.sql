USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_FACT_ALL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_FACT_ALL_GET]  AS SELECT 1')
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[ACT_FACT_ALL_GET]
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

		SELECT AFM_DATE, ACT_DATE = IsNull(Max(ACT_DATE), AFM_DATE), COUNT(*) AS AFM_COUNT
		FROM dbo.ActFactMasterTable M
		LEFT JOIN dbo.ActTable A ON M.ACT_ID = A.ACT_ID
		GROUP BY AFM_DATE
		ORDER BY AFM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_FACT_ALL_GET] TO rl_act_p;
GO
