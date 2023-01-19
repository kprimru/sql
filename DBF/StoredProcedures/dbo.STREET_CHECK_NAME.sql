USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STREET_CHECK_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STREET_CHECK_NAME]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает ID улицы с указанным
               названием в указанном населенном
               пункте.
*/

ALTER PROCEDURE [dbo].[STREET_CHECK_NAME]
	@streetname VARCHAR(100),
	@cityid SMALLINT,
	@prefix VARCHAR(10) = NULL
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

		SELECT ST_ID
		FROM dbo.StreetTable
		WHERE ST_NAME = @streetname AND ST_ID_CITY = @cityid
			AND ST_PREFIX = @prefix

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STREET_CHECK_NAME] TO rl_street_w;
GO
