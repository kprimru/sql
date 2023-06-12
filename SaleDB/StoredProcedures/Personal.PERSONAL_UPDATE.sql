USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_UPDATE]
	@ID			UNIQUEIDENTIFIER,
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
	@START_DATE	DATETIME
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
		UPDATE	Personal.OfficePersonal
		SET		MANAGER		=	@MANAGER,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				SHORT		=	@SHORT,
				PHONE		=	@PHONE,
				PHONE_OFFICE	=	@PHONE_OF,
				LOGIN		=	@LOGIN,
				PASS		=	@PASS,
				START_DATE	=	@START_DATE,
				LAST	=	GETDATE()
		WHERE	ID		=	@ID

		UPDATE	Personal.OfficePersonalType
		SET		EDATE	=	GETDATE()
		WHERE	ID_PERSONAL	=	@ID
			AND	EDATE IS NULL
			AND ID_TYPE NOT IN
				(
					SELECT *
					FROM Common.TableGUIDFromXML(@ID_TYPE)
				)

		INSERT INTO Personal.OfficePersonalType(ID_PERSONAL, ID_TYPE)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ID_TYPE) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Personal.OfficePersonalType b
					WHERE ID_PERSONAL = @ID
						AND EDATE IS NULL
						AND a.ID = b.ID_TYPE
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_UPDATE] TO rl_personal_w;
GO
