USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CITY_INSERT]
	@REGION		UNIQUEIDENTIFIER,
	@AREA		UNIQUEIDENTIFIER,
	@CITY		UNIQUEIDENTIFIER,
	@NAME		VARCHAR(100),
	@PREFIX		VARCHAR(20),
	@SUFFIX		VARCHAR(20),
	@DISPLAY	BIT,
	@DEFAULT	BIT,
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL	TABLE (ID UNIQUEIDENTIFIER)

		IF @DEFAULT = 1
			UPDATE dbo.CityTable
			SET CT_DEFAULT = 0
			WHERE CT_DEFAULT = 1

		INSERT INTO dbo.City(CT_ID_REGION, CT_ID_AREA, CT_ID_CITY, CT_NAME, CT_PREFIX, CT_SUFFIX, CT_DISPLAY, CT_DEFAULT)
			OUTPUT INSERTED.CT_ID INTO @TBL
			VALUES(@REGION, @AREA, @CITY, @NAME, @PREFIX, @SUFFIX, @DISPLAY, @DEFAULT)

		SELECT @ID = ID FROM @TBL

		INSERT INTO dbo.Street(ST_ID_CITY, ST_NAME, ST_PREFIX, ST_SUFFIX)
			VALUES(@ID, 'Без улицы', '', '')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CITY_INSERT] TO rl_city_i;
GO
