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

ALTER PROCEDURE [dbo].[SYSTEM_NET_COUNT_ADD]
	@systemnetid INT,
	@netcount INT,
	@TECH SMALLINT,
	@ODOFF	SMALLINT,
	@ODON	SMALLINT,
	@SHORT	VARCHAR(50),
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

		INSERT INTO dbo.SystemNetCountTable(SNC_ID_SN, SNC_NET_COUNT, SNC_TECH, SNC_ACTIVE, SNC_ODON, SNC_ODOFF, SNC_SHORT)
		VALUES (@systemnetid, @netcount, @tech, @active, @ODON, @ODOFF, @SHORT)

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
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COUNT_ADD] TO rl_system_net_count_w;
GO
