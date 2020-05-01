USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [IP].[LIST_INCLUDE]
	@TP		TINYINT,
	@HOST	SMALLINT,
	@DISTR	INT,
	@COMP	TINYINT,
	@NOTE	NVARCHAR(MAX)
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

		INSERT INTO IP.Lists(ID_HOST, DISTR, COMP, TP, SET_DATE, SET_USER, SET_REASON)
			SELECT @HOST, @DISTR, @COMP, @TP, GETDATE(), ORIGINAL_LOGIN(), @NOTE
			WHERE NOT EXISTS
				(
					SELECT *
					FROM IP.Lists
					WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND TP = @TP AND UNSET_DATE IS NULL
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [IP].[LIST_INCLUDE] TO rl_ip_list;
GO