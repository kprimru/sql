USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[NET_TYPE_INSERT]
	@NAME	VARCHAR(100),
	@NOTE	VARCHAR(50),
	@NET	SMALLINT,
	@TECH	SMALLINT,
	@SHORT	VARCHAR(20),
	@MASTER	INT,
	@VMI_SHORT	VARCHAR(50),
	@ODOFF	SMALLINT,
	@ODON	SMALLINT,
	@TECH_USR	VarChar(20),
	@ID		INT = NULL OUTPUT
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

		INSERT INTO Din.NetType(NT_NAME, NT_NOTE, NT_NET, NT_TECH, NT_SHORT, NT_ID_MASTER, NT_VMI_SHORT, NT_ODOFF, NT_ODON, NT_TECH_USR)
			VALUES(@NAME, @NOTE, @NET, @TECH, @SHORT, @MASTER, @VMI_SHORT, @ODOFF, @ODON, @TECH_USR)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[NET_TYPE_INSERT] TO rl_din_net_type_i;
GO