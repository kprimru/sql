USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[SYSTEM_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256),
	@SHORT	NVARCHAR(64),
	@REG	NVARCHAR(64),
	@ORD	SMALLINT
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
		UPDATE	System.Systems
		SET		NAME		=	@NAME,
				SHORT		=	@SHORT,
				REG			=	@REG,
				ORD			=	@ORD,
				LAST		=	GETDATE()
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
GRANT EXECUTE ON [System].[SYSTEM_UPDATE] TO rl_system_w;
GO