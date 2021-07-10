USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:
Дата создания:	17.02.2009
Описание:		Процедура получения отчёта ВМИ
					из истории отчётов (по периоду)
*/

ALTER PROCEDURE [dbo].[RIC_REPORT_HISTORY_BY_PERIOD_GET]
	@periodid SMALLINT
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
			--PR_NAME,
			VRH_RIC_NUM, VRH_TO_NUM, VRH_TO_NAME,
			VRH_INN, VRH_REGION, VRH_CITY, VRH_ADDR,
			VRH_FIO_1, VRH_JOB_1, VRH_TELS_1,
			VRH_FIO_2, VRH_JOB_2, VRH_TELS_2,
			VRH_FIO_3, VRH_JOB_3, VRH_TELS_3,
			VRH_FIO_4, VRH_JOB_4, VRH_TELS_4,
			VRH_FIO_5, VRH_JOB_5, VRH_TELS_5,
			VRH_SERV, VRH_DISTR, VRH_COMMENT

		FROM	dbo.VRHView
		WHERE	PR_ID=@periodid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[RIC_REPORT_HISTORY_BY_PERIOD_GET] TO rl_vmi_history_r;
GO