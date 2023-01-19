USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[COURIER_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[COURIER_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[COURIER_EDIT]
	@courierid SMALLINT,
	@couriername VARCHAR(100),
	@TYPE SMALLINT,
	@active BIT = 1,
	@city SMALLINT = NULL
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

		UPDATE dbo.CourierTable
		SET COUR_NAME = @couriername,
			COUR_ID_TYPE = @TYPE,
			COUR_ID_CITY = @city,
			COUR_ACTIVE = @active
		WHERE COUR_ID = @courierid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[COURIER_EDIT] TO rl_courier_w;
GO
