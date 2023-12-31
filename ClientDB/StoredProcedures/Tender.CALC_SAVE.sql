USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[CALC_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@TENDER		UNIQUEIDENTIFIER,
	@DIRECTION	UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(128),
	@PRICE		MONEY,
	@NOTE		NVARCHAR(MAX),
	@CALC_DATA	NVARCHAR(MAX)
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

		IF @ID IS NULL
			INSERT INTO Tender.Calc(ID_TENDER, ID_DIRECTION, NAME, PRICE, CALC_DATA, NOTE)
				SELECT @TENDER, @DIRECTION, @NAME, @PRICE, @CALC_DATA, @NOTE
		ELSE
			UPDATE Tender.Calc
			SET ID_DIRECTION	=	@DIRECTION,
				NAME			=	@NAME,
				PRICE			=	@PRICE,
				CALC_DATA		=	@CALC_DATA,
				NOTE			=	@NOTE,
				UPD_DATE		=	GETDATE(),
				UPD_USER		=	ORIGINAL_LOGIN()
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CALC_SAVE] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[CALC_SAVE] TO rl_tender_u;
GO
