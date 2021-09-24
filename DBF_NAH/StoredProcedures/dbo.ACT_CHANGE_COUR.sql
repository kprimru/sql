USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CHANGE_COUR]
	@actid INT,
	@courid SMALLINT
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

		UPDATE dbo.ActTable
		SET ACT_ID_COUR = @courid
		WHERE ACT_ID = @actid

		DECLARE @CLIENT	INT
		DECLARE @TXT	VARCHAR(MAX)

		EXEC dbo.ACT_PROTOCOL @actid, @CLIENT OUTPUT, @TXT OUTPUT

		EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', 'Смена СИ', @TXT, @CLIENT, @actid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_CHANGE_COUR] TO rl_act_w;
GO
