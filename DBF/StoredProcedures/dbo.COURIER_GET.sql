USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[COURIER_GET]
	@courierid SMALLINT
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

		SELECT COUR_NAME, COUR_ID, COUR_ACTIVE, COT_ID, COT_NAME, CT_ID, CT_NAME
		FROM
			dbo.CourierTable LEFT OUTER JOIN
			dbo.CourierTypeTable ON COT_ID = COUR_ID_TYPE LEFT OUTER JOIN
			dbo.CityTable ON CT_ID = COUR_ID_CITY
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
GRANT EXECUTE ON [dbo].[COURIER_GET] TO rl_courier_r;
GO