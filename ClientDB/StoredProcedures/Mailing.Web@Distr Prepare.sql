USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Mailing].[Web@Distr Prepare]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Mailing].[Web@Distr Prepare]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Mailing].[Web@Distr Prepare]
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

		DELETE
		FROM OPENQUERY([WEBSITE], 'SELECT DISTR FROM cons_din');

		INSERT INTO OPENQUERY([WEBSITE], 'SELECT DISTR FROM cons_din')
		SELECT DISTINCT DistrNumber
		FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
		WHERE Service = 0;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
