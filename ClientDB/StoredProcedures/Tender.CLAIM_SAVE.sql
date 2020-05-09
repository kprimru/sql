USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[CLAIM_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@TENDER		UNIQUEIDENTIFIER,
	@TP			TINYINT,
	@DATE		DATETIME,
	@TPARAMS	NVARCHAR(MAX),
	@RETURN		NVARCHAR(256)
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

		SET @TPARAMS = REPLACE(@TPARAMS, CHAR(9), '')
		SET @TPARAMS = REPLACE(@TPARAMS, CHAR(13), '')

		UPDATE Tender.Claim
		SET CLAIM_DATE			=	@DATE,
			PARAMS				=	@TPARAMS,
			PROVISION_RETURN	=	@RETURN
		WHERE ID = @ID

		IF @@ROWCOUNT = 0
			INSERT INTO Tender.Claim(ID_TENDER, TP, CLAIM_DATE, PARAMS, PROVISION_RETURN)
				VALUES(@TENDER, @TP, @DATE, @TPARAMS, @RETURN)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CLAIM_SAVE] TO rl_tender_u;
GO