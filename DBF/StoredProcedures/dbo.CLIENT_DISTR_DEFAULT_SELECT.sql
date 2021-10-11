USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_DEFAULT_SELECT]
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
		-- 4 варианта: обслуживание и подхост
		DECLARE @service SMALLINT
		DECLARE @subhost SMALLINT

		SELECT @service = RN_SERVICE, @subhost = RN_SUBHOST
		FROM
			dbo.RegNodeTable INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON SYS_REG_NAME = RN_SYS_NAME
						AND DIS_NUM = RN_DISTR_NUM
						AND DIS_COMP_NUM = RN_COMP_NUM
		WHERE DIS_ID = @distrid

		IF @subhost = 1
			SELECT DSS_ID, DSS_NAME
			FROM dbo.DistrServiceStatusTable
			WHERE DSS_SUBHOST = 1
		ELSE IF @service = 0
			SELECT DSS_ID, DSS_NAME
			FROM dbo.DistrServiceStatusTable
			WHERE DSS_ID_STATUS = 1
		ELSE IF @service = 1
			SELECT DSS_ID, DSS_NAME
			FROM dbo.DistrServiceStatusTable
			WHERE DSS_ID_STATUS = 2
		ELSE
			SELECT 0 AS DSS_ID, '' AS DSS_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DEFAULT_SELECT] TO rl_client_distr_r;
GO
