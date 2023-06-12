USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_TYPE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_TYPE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_TYPE_INSERT]
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64),
	@PSEDO	NVARCHAR(64),
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
		INSERT INTO Personal.PersonalType(NAME, SHORT, PSEDO)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @SHORT, @PSEDO)

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
GRANT EXECUTE ON [Personal].[PERSONAL_TYPE_INSERT] TO rl_personal_type_w;
GO
