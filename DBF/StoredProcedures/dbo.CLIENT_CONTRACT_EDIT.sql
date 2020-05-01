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

ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_EDIT]
	@contractid INT,
	@contractnumber VARCHAR(500),
	@contracttypeid SMALLINT,
	@contractdate SMALLDATETIME,
	@contractbegin SMALLDATETIME,
	@contractend SMALLDATETIME,
	@pay SMALLINT,
	@kind SMALLINT,
	@active BIT,
	@ident	nvarchar(128),
	@key		NvarChar(256),
	@num_from	NvarChar(256),
	@num_to		NvarChar(256),
	@email		NvarChar(256)
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

		UPDATE dbo.ContractTable
		SET CO_NUM = @contractnumber,
			CO_ID_TYPE = @contracttypeid,
			CO_DATE = @contractdate,
			CO_BEG_DATE = @contractbegin,
			CO_END_DATE = @contractend,
			CO_ID_PAY = @pay,
			CO_ID_KIND = @kind,
			CO_ACTIVE	= @active,
			CO_IDENT = @ident,
			CO_KEY = @key,
			CO_NUM_FROM = @num_from,
			CO_NUM_TO = @num_to,
			CO_EMAIL = @email
		WHERE CO_ID = @contractid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_EDIT] TO rl_client_contract_w;
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_EDIT] TO rl_client_w;
GO