USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[WORK_STATE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(512),
	@SALE	BIT,
	@PHONE	BIT,
	@ARCH	BIT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		UPDATE	Client.WorkState
		SET		NAME	=	@NAME,
				SALE_AUTO	=	@SALE,
				PHONE_AUTO	=	@PHONE,
				ARCHIVE_AUTO	=	@ARCH,
				LAST	=	GETDATE()
		WHERE	ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[WORK_STATE_UPDATE] TO rl_work_state_w;
GO