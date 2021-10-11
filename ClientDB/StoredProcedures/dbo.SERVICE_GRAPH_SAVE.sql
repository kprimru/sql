USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_GRAPH_SAVE]
	@CLIENT	INT,
	@DAY	INT,
	@START	DATETIME,
	@LENGTH	SMALLINT
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

		UPDATE dbo.ClientTable
		SET DayID					=	@DAY,
			ServiceStart			=	@START,
			ServiceTime				=	@LENGTH,
			ClientLast				=	GETDATE(),
			UPD_USER				=	ORIGINAL_LOGIN()
		WHERE ClientID = @CLIENT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_GRAPH_SAVE] TO rl_service_graph_u;
GO
