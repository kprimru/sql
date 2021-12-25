USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:
Дата:			16.07.2009
*/

ALTER PROCEDURE [dbo].[ADDRESS_TEMPLATE_ADD]
--	@atlid			SMALLINT,
	@name			VARCHAR(50),
	@index			BIT,
	@country		BIT,
	@region			BIT,
	@area			BIT,
	@city_prefix	BIT,
	@city			BIT,
	@str_prefix		BIT,
	@street			BIT,
	@home			BIT,
	@active			BIT = 1,
	@returnvalue	BIT = 1
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

		INSERT INTO dbo.AddressTemplateTable (
			ATL_CAPTION,
			ATL_INDEX,
			ATL_COUNTRY,
			ATL_REGION,
			ATL_AREA,
			ATL_CITY_PREFIX,
			ATL_CITY,
			ATL_STR_PREFIX,
			ATL_STREET,
			ATL_HOME,
			ATL_ACTIVE
		) VALUES (
			@name,
			@index,
			@country,
			@region,
			@area,
			@city_prefix,
			@city,
			@str_prefix,
			@street,
			@home,
			@active
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
GRANT EXECUTE ON [dbo].[ADDRESS_TEMPLATE_ADD] TO rl_address_template_w;
GO
