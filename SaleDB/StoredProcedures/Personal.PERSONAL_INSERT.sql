USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_INSERT]
	@MANAGER	UNIQUEIDENTIFIER,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@SHORT		NVARCHAR(128),
	@PHONE		NVARCHAR(128),
	@PHONE_OF	NVARCHAR(128),
	@ID_TYPE	NVARCHAR(MAX),
	@AUTH		SMALLINT,
	@LOGIN		NVARCHAR(128),
	@PASS		NVARCHAR(128),
	@ROLE		UNIQUEIDENTIFIER,
	@START_DATE	SMALLDATETIME,
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
WITH EXECUTE AS OWNER
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
		IF @START_DATE IS NULL
			SET @START_DATE = Common.DateOf(GETDATE())

		INSERT INTO Personal.OfficePersonal(MANAGER, SURNAME, NAME, PATRON, SHORT, LOGIN, PASS, START_DATE, PHONE, PHONE_OFFICE)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@MANAGER, @SURNAME, @NAME, @PATRON, @SHORT, @LOGIN, @PASS, @START_DATE, @PHONE, @PHONE_OF)

		SELECT @ID = ID FROM @TBL

		INSERT INTO Personal.OfficePersonalType(ID_PERSONAL, ID_TYPE)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ID_TYPE)

		IF @LOGIN IS NOT NULL AND @PASS IS NOT NULL
			EXEC Security.USER_CREATE @AUTH, @LOGIN, @SHORT, @PASS, @ROLE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_INSERT] TO rl_personal_w;
GO