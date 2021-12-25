USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Address].[STREET_INSERT]
	@NAME	NVARCHAR(256),
	@PREFIX	NVARCHAR(32),
	@SUFFIX	NVARCHAR(32),
	@CITY	UNIQUEIDENTIFIER,
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
		INSERT INTO Address.Street(NAME, PREFIX, SUFFIX, ID_CITY)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@NAME, @PREFIX, @SUFFIX, @CITY)

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
GRANT EXECUTE ON [Address].[STREET_INSERT] TO rl_street_w;
GO
