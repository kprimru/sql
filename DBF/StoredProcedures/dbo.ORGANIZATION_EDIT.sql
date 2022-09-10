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

ALTER PROCEDURE [dbo].[ORGANIZATION_EDIT]
	@id         SmallInt,
	@psedo      VarChar(50),
	@fullname   VarChar(250),
	@shortname  VarChar(50),
	@org1c      VarChar(50),
	@index      VarChar(50),
	@streetid   Int,
	@home       VarChar(100),
	@sindex     VarChar(50),
	@sstreetid  Int,
	@shome      VarChar(100),
	@phone      VarChar(100),
	@email      VarChar(100),
	@bankid     SmallInt,
	@acc        VarChar(50),
	@loro       VarChar(50),
	@bik        VarChar(50),
	@inn        VarChar(50),
	@kpp        VarChar(50),
	@okonh      VarChar(50),
	@okpo       VarChar(50),
	@buhfam     VarChar(50),
	@buhname    VarChar(50),
	@buhotch    VarChar(50),
	@dirfam     VarChar(50),
	@dirname    VarChar(50),
	@dirotch    VarChar(50),
	@dirpos     VarChar(100),
	@billshort  VarChar(100),
	@billpos    VarChar(100),
	@billmemo   VarChar(100),
	@eiscode    VarChar(100),
	@eiscommcode    VarChar(100),
	@logo		VarBinary(Max),
	@active     Bit = 1
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

		UPDATE dbo.OrganizationTable
		SET ORG_PSEDO       = @psedo,
			ORG_FULL_NAME   = @fullname,
			ORG_SHORT_NAME  = @shortname,
			ORG_1C          = @Org1c,
			ORG_INDEX       = @index,
			ORG_ID_STREET   = @streetid,
			ORG_HOME        = @home,
			ORG_S_INDEX     = @sindex,
			ORG_S_ID_STREET = @sstreetid,
			ORG_S_HOME      = @shome,
			ORG_PHONE       = @phone,
			ORG_EMAIL       = @email,
			ORG_ID_BANK     = @bankid,
			ORG_ACCOUNT     = @acc,
			ORG_LORO        = @loro,
			ORG_BIK         = @bik,
			ORG_INN         = @inn,
			ORG_KPP         = @kpp,
			ORG_OKONH       = @okonh,
			ORG_OKPO        = @okpo,
			ORG_BUH_FAM     = @buhfam,
			ORG_BUH_NAME    = @buhname,
			ORG_BUH_OTCH    = @buhotch,
			ORG_DIR_FAM     = @dirfam,
			ORG_DIR_NAME    = @dirname,
			ORG_DIR_OTCH    = @dirotch,
			ORG_DIR_POS     = @dirpos,
			ORG_BILL_SHORT  = @billshort,
			ORG_BILL_POS    = @billpos,
			ORG_BILL_MEMO   = @billmemo,
			EIS_CODE        = @eiscode,
			EIS_COMM_CODE   = @eiscommcode,
			ORG_LOGO		= @logo,
			ORG_ACTIVE      = @active
		WHERE ORG_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ORGANIZATION_EDIT] TO rl_organization_w;
GO
