USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CITY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CITY_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CITY_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@REGION		UNIQUEIDENTIFIER,
	@AREA		UNIQUEIDENTIFIER,
	@CITY		UNIQUEIDENTIFIER,
	@NAME		VARCHAR(100),
	@PREFIX		VARCHAR(20),
	@SUFFIX		VARCHAR(20),
	@DISPLAY	BIT,
	@DEFAULT	BIT
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

		IF @DEFAULT = 1
			UPDATE dbo.City
			SET CT_DEFAULT = 0
			WHERE CT_DEFAULT = 1 AND CT_ID <> @ID

		UPDATE	dbo.City
		SET		CT_ID_REGION	=	@REGION,
				CT_ID_AREA		=	@AREA,
				CT_ID_CITY		=	@CITY,
				CT_NAME			=	@NAME,
				CT_PREFIX		=	@PREFIX,
				CT_SUFFIX		=	@SUFFIX,
				CT_DISPLAY		=	@DISPLAY,
				CT_DEFAULT		=	@DEFAULT
		WHERE	CT_ID			=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CITY_UPDATE] TO rl_city_u;
GO
