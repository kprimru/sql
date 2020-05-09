USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Reg].[ONLINE_PASSWORD_SET]
	@SYSTEM	INT,
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@PASS	NVARCHAR(MAX)
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

		UPDATE Reg.OnlinePassword
		SET STATUS = 2
		WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP

		INSERT INTO Reg.OnlinePassword(ID_SYSTEM, ID_HOST, DISTR, COMP, PASS)
			VALUES(@SYSTEM, @HOST, @DISTR, @COMP, @PASS)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[ONLINE_PASSWORD_SET] TO rl_reg_online;
GO