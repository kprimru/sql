USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_FINANCING_ADDRESS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_SELECT]  AS SELECT 1')
GO
/*
Автор:			Денисов Алексей
Описание:		Список адресов и их шаблонов в финансовых документах клиента
Дата:			17.07.2009
*/
ALTER PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_SELECT]
	@clientid INT
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

		SELECT CFA_ID, FAT_ID, FAT_NOTE, ATL_ID, ATL_CAPTION, ADDR_STRING
		FROM dbo.ClientFinancingAddressView
		WHERE CL_ID = @clientid
		ORDER BY FAT_NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_ADDRESS_SELECT] TO rl_client_fin_template_r;
GO
