USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:         Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[VMIREPORT_SELECT]
AS
BEGIN
	SET NOCOUNT ON

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
			VMR_RIC_NUM, VMR_TO_NUM, VMR_TO_NAME,
			VMR_INN, VMR_REGION, VMR_CITY, VMR_ADDR,
			VMR_FIO_1, VMR_JOB_1, VMR_TELS_1,
			VMR_FIO_2, VMR_JOB_2, VMR_TELS_2,
			VMR_FIO_3, VMR_JOB_3, VMR_TELS_3,
			VMR_FIO_4, VMR_JOB_4, VMR_TELS_4,
			VMR_FIO_5, VMR_JOB_5, VMR_TELS_5,
			VMR_SERV, VMR_DISTR, VMR_COMMENT

			FROM dbo.VMRView
			ORDER BY VMR_TO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[VMIREPORT_SELECT] TO rl_vmi_r;
GO
