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

ALTER PROCEDURE [dbo].[ORGANIZATION_ADD]
	@psedo VARCHAR(50),
	@fullname VARCHAR(250),
	@shortname VARCHAR(50),
	@index VARCHAR(50),
	@streetid INT,
	@home VARCHAR(100),
	@sindex VARCHAR(50),
	@sstreetid INT,
	@shome VARCHAR(100),
	@phone VARCHAR(50),
	@bankid SMALLINT,
	@acc VARCHAR(50),
	@loro VARCHAR(50),
	@bik VARCHAR(50),
	@inn VARCHAR(50),
	@kpp VARCHAR(50),
	@okonh VARCHAR(50),
	@okpo VARCHAR(50),
	@buhfam VARCHAR(50),
	@buhname VARCHAR(50),
	@buhotch VARCHAR(50),
	@dirfam VARCHAR(50),
	@dirname VARCHAR(50),
	@dirotch VARCHAR(50),
	@active BIT = 1,
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

		INSERT INTO dbo.OrganizationTable
			(
				ORG_PSEDO, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INDEX, ORG_ID_STREET,
				ORG_HOME, ORG_S_INDEX, ORG_S_ID_STREET, ORG_S_HOME, ORG_PHONE,
				ORG_ID_BANK, ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH,
				ORG_OKPO, ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH, ORG_DIR_FAM,
				ORG_DIR_NAME,ORG_DIR_OTCH, ORG_ACTIVE
			)
		VALUES
			(
				@psedo, @fullname, @shortname, @index, @streetid, @home, @sindex, @sstreetid,
				@shome,	@phone,	@bankid, @acc, @loro, @bik, @inn,	@kpp, @okonh, @okpo,
				@buhfam, @buhname, @buhotch, @dirfam, @dirname, @dirotch, @active
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
GRANT EXECUTE ON [dbo].[ORGANIZATION_ADD] TO rl_organization_w;
GO