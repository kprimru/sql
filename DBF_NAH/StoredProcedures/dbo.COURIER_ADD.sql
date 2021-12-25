USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[COURIER_ADD]
	@couriername VARCHAR(150),
	@type SMALLINT,
	@active BIT = 1,
	@oldcode INT = NULL,
	@city SMALLINT = NULL,
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

		INSERT INTO dbo.CourierTable (COUR_NAME, COUR_ID_TYPE, COUR_ID_CITY, COUR_ACTIVE, COUR_OLD_CODE)
		VALUES (@couriername, @type, @city, @active, @oldcode)

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
GRANT EXECUTE ON [dbo].[COURIER_ADD] TO rl_courier_w;
GO
