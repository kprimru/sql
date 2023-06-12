USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Meeting].[CLIENT_MEETING_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Meeting].[CLIENT_MEETING_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Meeting].[CLIENT_MEETING_DELETE]
	@ID				UNIQUEIDENTIFIER
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
		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = b.ID_COMPANY
		FROM
			Meeting.ClientMeeting a
			INNER JOIN Meeting.AssignedMeeting b ON a.ID_ASSIGNED = b.ID
		WHERE a.ID = @ID

		DELETE
		FROM Meeting.ClientMeeting
		WHERE ID = @ID

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN ClientMeeting

		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_DELETE] TO rl_meeting_d;
GO
