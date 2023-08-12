USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_TYPE_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_TYPE_COEF_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SYSTEM_TYPE_COEF_SELECT]
	@TYPE		Int,
	@PERIOD		UniqueIdentifier = NULL
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

		SELECT P.[NAME], C.[SystemTypeName], a.[Coef], a.[Round], a.[Date], c.[SystemTypeID]
		FROM [Price].[SystemType:Coef]		AS a
		INNER JOIN [dbo].[SystemTypeTable]	AS c ON c.[SystemTypeID] = a.[SystemType_Id]
		INNER JOIN [Common].[Period]		AS P ON P.[START] = a.[Date] AND P.[TYPE] = 2
		WHERE (a.[SystemType_Id] = @TYPE OR @TYPE IS NULL)
		ORDER BY a.[Date] DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
