USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_REG_NODE_ALL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_REG_NODE_ALL]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[GET_REG_NODE_ALL]
WITH EXECUTE AS OWNER
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

		-- ToDo да что же это такое...
		SELECT R.*, S.SystemID, S.SystemShortName
		FROM dbo.RegNodeTable R
		LEFT JOIN dbo.SystemTable S ON S.SystemBaseName = R.SystemName
		ORDER BY S.SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_REG_NODE_ALL] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[GET_REG_NODE_ALL] TO BL_EDITOR;
GRANT EXECUTE ON [dbo].[GET_REG_NODE_ALL] TO BL_PARAM;
GRANT EXECUTE ON [dbo].[GET_REG_NODE_ALL] TO BL_READER;
GRANT EXECUTE ON [dbo].[GET_REG_NODE_ALL] TO BL_RGT;
GO
