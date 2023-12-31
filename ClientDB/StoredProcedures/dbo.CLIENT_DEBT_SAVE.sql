USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DEBT_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@CLIENT	INT,
	@DEBT	UNIQUEIDENTIFIER,
	@START	UNIQUEIDENTIFIER,
	@FINISH	UNIQUEIDENTIFIER,
	@NOTE	NVARCHAR(MAX)
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
			INSERT INTO dbo.ClientDebt(ID_CLIENT, ID_DEBT, START, FINISH, NOTE)
				VALUES(@CLIENT, @DEBT, @START, @FINISH, @NOTE)
		ELSE
			UPDATE dbo.ClientDebt
			SET ID_DEBT	=	@DEBT,
				START	=	@START,
				FINISH	=	@FINISH,
				NOTE	=	@NOTE
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
GRANT EXECUTE ON [dbo].[CLIENT_DEBT_SAVE] TO rl_client_debt_u;
GO
