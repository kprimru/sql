USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные об улице
               с указанным кодом
*/

ALTER PROCEDURE [dbo].[STREET_EDIT]
	@streetid INT,
	@streetname VARCHAR(150),
	@streetprefix VARCHAR(10),
	@streetsuffix VARCHAR(10),
	@cityid SMALLINT,
	@active BIT = 1
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

		UPDATE dbo.StreetTable
		SET ST_NAME = @streetname,
			ST_ID_CITY = @cityid,
			ST_PREFIX = @streetprefix,
			ST_SUFFIX = @streetsuffix,
			ST_ACTIVE = @active
		WHERE ST_ID = @streetid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[STREET_EDIT] TO rl_street_w;
GO
