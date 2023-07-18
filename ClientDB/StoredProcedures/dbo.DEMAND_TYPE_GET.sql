﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DEMAND_TYPE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DEMAND_TYPE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DEMAND_TYPE_GET]
	@ID	INT
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

		SELECT	[Id],
				[Name],
				[Code],
				[SortIndex]
		FROM [dbo].[Demand->Type]
		WHERE [Id] = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DEMAND_TYPE_GET] TO rl_demand_type_r;
GO