USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_EDIT]  AS SELECT 1')
GO

/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_EDIT]
	@csgid INT,
	@csgidorg SMALLINT,
	@csgidclient INT,
	@csgconsignname VARCHAR(250),
	@csgconsignaddress VARCHAR(250),
	@inn VARCHAR(50),
	@kpp VARCHAR(50),
	@csgconsignokpo VARCHAR(250),
	@csgclientname VARCHAR(250),
	@csgclientaddress VARCHAR(250),
	@phone VARCHAR(50),
	@bank VARCHAR(500),
	@csgfound VARCHAR(100),
	@csgnum VARCHAR(50),
	@csgdate SMALLDATETIME
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

		UPDATE dbo.ConsignmentTable
		SET CSG_ID_ORG = @csgidorg,
			CSG_ID_CLIENT = @csgidclient,
			CSG_CONSIGN_NAME = @csgconsignname,
			CSG_CONSIGN_ADDRESS = @csgconsignaddress,
			CSG_CONSIGN_INN = @inn,
			CSG_CONSIGN_KPP = @kpp,
			CSG_CONSIGN_OKPO = @csgconsignokpo,
			CSG_CLIENT_NAME = @csgclientname,
			CSG_CLIENT_ADDRESS = @csgclientaddress,
			CSG_CLIENT_PHONE = @phone,
			CSG_CLIENT_BANK = @bank,
			CSG_FOUND = @csgfound,
			CSG_NUM = @csgnum,
			CSG_DATE = @csgdate
		WHERE CSG_ID = @csgid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_EDIT] TO rl_consignment_w;
GO
