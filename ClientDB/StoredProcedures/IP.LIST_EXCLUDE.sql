USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [IP].[LIST_EXCLUDE]
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

		UPDATE IP.Lists
		SET UNSET_DATE		=	GETDATE(),
			UNSET_USER		=	ORIGINAL_LOGIN(),
			UNSET_REASON	=	@NOTE
		WHERE ID_HOST = @HOST
			AND DISTR = @DISTR
			AND COMP = @COMP
			AND TP = @TP
			AND UNSET_DATE IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [IP].[LIST_EXCLUDE] TO rl_ip_list;
GO