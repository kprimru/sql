USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CITY_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CITY_ADD]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CITY_ADD]
	@cityname VARCHAR(100),
	@cityprefix VARCHAR(50),
	@phone VARCHAR(50),
	@regionid INT,
	@areaid INT,
	@countryid INT,
	@region TINYINT,
	@active BIT = 1,
	@base SMALLINT = NULL,
	--@oldcode INT = NULL,
	@returnvalue BIT = 1

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

		INSERT INTO dbo.CityTable
							(
								CT_PREFIX, CT_NAME, CT_PHONE, CT_ID_RG, CT_ID_AREA,
								CT_ID_COUNTRY, CT_REGION, CT_ACTIVE, /*CT_OLD_CODE, */CT_ID_BASE
							)
		VALUES (
				@cityprefix, @cityname, @phone, @regionid,
				@areaid, @countryid, @region, @active, /*@oldcode, */@base
				)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CITY_ADD] TO rl_city_w;
GO
