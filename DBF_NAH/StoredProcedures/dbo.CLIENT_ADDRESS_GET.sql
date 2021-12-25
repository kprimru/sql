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

ALTER PROCEDURE [dbo].[CLIENT_ADDRESS_GET]
	@clientaddressid INT
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

		SELECT
				CA_ID, CA_INDEX, CA_HOME, CA_STR, CA_FREE, ST_NAME,
				ST_ID, CT_NAME, CT_ID, AT_ID, AT_NAME, ATL_ID, ATL_CAPTION
		FROM dbo.ClientAddressView
		WHERE CA_ID = @clientaddressid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_GET] TO rl_client_address_r;
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_GET] TO rl_client_r;
GO
