USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PROVISION_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PROVISION_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PROVISION_SAVE]
	@ID		INT,
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@PRICE	MONEY,
	@NUM	INT,
	@ORG	SMALLINT
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

		IF @ID IS NULL
			INSERT INTO dbo.Provision(ID_CLIENT, DATE, PRICE, PAY_NUM, ID_ORG)
				VALUES(@CLIENT, @DATE, @PRICE, @NUM, @ORG)
		ELSE
			UPDATE dbo.Provision
			SET	DATE	=	@DATE,
				PRICE	=	@PRICE,
				PAY_NUM	=	@NUM,
				ID_ORG	=	@ORG
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PROVISION_SAVE] TO rl_income_w;
GO
