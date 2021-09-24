USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[NetType@Select?Synonyms]
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

		SELECT N.NT_ID, S.NT_NAME, S.NT_NOTE, N.NT_SHORT
		FROM Din.NetType AS N
		INNER JOIN Din.[NetType:Synonyms] AS S ON N.NT_ID = S.Net_Id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[NetType@Select?Synonyms] TO rl_din_import;
GRANT EXECUTE ON [Din].[NetType@Select?Synonyms] TO rl_din_net_type_r;
GO
