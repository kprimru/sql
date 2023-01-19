USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_NET_COUNT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_GET]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COUNT_GET]
	@systemnetcountid SMALLINT = NULL
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

		SELECT SN_NAME, SN_ID, SNC_NET_COUNT, SNC_TECH, SNC_ACTIVE, SNC_ODON, SNC_ODOFF, SNC_SHORT
		FROM
			dbo.SystemNetCountTable a INNER JOIN
			dbo.SystemNetTable b ON a.SNC_ID_SN = b.SN_ID
		WHERE SNC_ID = @systemnetcountid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COUNT_GET] TO rl_system_net_count_r;
GO
