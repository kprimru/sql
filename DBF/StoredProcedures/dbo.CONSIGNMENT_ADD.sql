USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[CONSIGNMENT_ADD]
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

		INSERT INTO dbo.ConsignmentTable 
			(
				CSG_ID_ORG, CSG_ID_CLIENT, CSG_CONSIGN_NAME, CSG_CONSIGN_ADDRESS,
				CSG_CONSIGN_INN, CSG_CONSIGN_KPP, CSG_CONSIGN_OKPO, 
				CSG_CLIENT_NAME, CSG_CLIENT_ADDRESS, CSG_CLIENT_PHONE, CSG_CLIENT_BANK,
				CSG_FOUND,	CSG_NUM, CSG_DATE
			)
		VALUES 
			(
				@csgidorg, @csgidclient, @csgconsignname, @csgconsignaddress,
				@inn, @kpp, @csgconsignokpo, @csgclientname, @csgclientaddress,	@phone, @bank,
				@csgfound, @csgnum, @csgdate
			)

		SELECT SCOPE_IDENTITY() AS NEW_IDEN
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
