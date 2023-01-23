USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_GET_EMAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_GET_EMAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_GET_EMAIL]
	@Id	UniqueIdentifier
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
			T.[Id], T.[Name], E.[Email]
		FROM [dbo].[SubhostEmail_Type] AS T
		LEFT JOIN [dbo].[SubhostEmail] AS E ON E.[Type_Id] = T.[Id] AND E.[Subhost_Id] = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_GET_EMAIL] TO rl_subhost_r;
GO
