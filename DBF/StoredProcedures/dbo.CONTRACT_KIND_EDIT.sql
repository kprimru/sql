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

ALTER PROCEDURE [dbo].[CONTRACT_KIND_EDIT]   
	@ID		SMALLINT,
	@NAME	VARCHAR(100),
	@HEADER VARCHAR(100),
	@CENTER	VARCHAR(100),
	@FOOTER	VARCHAR(100),
	@active BIT = 1
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
	
		UPDATE dbo.ContractKind
		SET CK_NAME	=	@NAME,
			CK_HEADER	=	@HEADER,
			CK_CENTER	=	@CENTER,
			CK_FOOTER	=	@FOOTER,
			CK_ACTIVE	=	@ACTIVE
		WHERE CK_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CONTRACT_KIND_EDIT] TO rl_contract_kind_w;
GO