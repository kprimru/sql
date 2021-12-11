USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_REG_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_REG_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_REG_SELECT]
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

		SELECT DISTINCT SubhostName, CASE SubhostName WHEN '' THEN 'Владивосток' ELSE SubhostName END AS SubhostCaption
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND) 
		ORDER BY SubhostName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_REG_SELECT] TO public;
GO
