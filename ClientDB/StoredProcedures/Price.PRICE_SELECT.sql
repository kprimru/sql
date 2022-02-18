﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_SELECT]
	@MONTH	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = START
		FROM [Common].[Period]
		WHERE [ID] = @MONTH;

		SELECT SystemID, SystemShortName, PRICE
		FROM [Price].[Systems:Price@Get](@Date) AS P
		INNER JOIN [dbo].[SystemTable]			AS S ON S.[SystemID] = P.[System_Id]
		ORDER BY SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_SELECT] TO rl_price_r;
GO
