USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[System].[SYSTEM_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [System].[SYSTEM_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [System].[SYSTEM_INSERT]
	@NAME	NVARCHAR(256),
	@SHORT	NVARCHAR(64),
	@REG	NVARCHAR(64),
	@ORD	INT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

	DECLARE @TBL TABLE
		(
			ID	UNIQUEIDENTIFIER
		)

	BEGIN TRY
		INSERT INTO System.Systems(NAME, SHORT, REG, ORD)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @SHORT, @REG, @ORD)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [System].[SYSTEM_INSERT] TO rl_system_w;
GO
