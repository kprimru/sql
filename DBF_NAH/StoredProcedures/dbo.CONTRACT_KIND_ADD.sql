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

ALTER PROCEDURE [dbo].[CONTRACT_KIND_ADD]
	@NAME	VARCHAR(100),
	@HEADER VARCHAR(100),
	@CENTER	VARCHAR(100),
	@FOOTER	VARCHAR(100),
	@CREATIVE   VARCHAR(100),
	@PREPOSITIONAL varchar(100),
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

		INSERT INTO dbo.ContractKind(CK_NAME, CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL, CK_ACTIVE)
			VALUES (@NAME, @HEADER, @CENTER, @FOOTER, @CREATIVE, @PREPOSITIONAL, @ACTIVE)

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
GRANT EXECUTE ON [dbo].[CONTRACT_KIND_ADD] TO rl_contract_kind_w;
GO
